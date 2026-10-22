# UO Libraries Omeka-S Digital Exhibits

The University of Oregon has two instances of Omeka-S: Red and Mellon.

Red houses the 'Red Thread' digital exhibit at https://redthread.uoregon.edu.

Mellon hosts 'Tekagami and Kyōgire', 'The Artful Fabric of Collecting', 'Windows to the Ainu World', 'Yokai Senjafuda', and other under-construction exhibits at https://glam.uoregon.edu.

These two instances are separate because of some custom features that were built into Red Thread.

Both instances are running Omeka-S v3.2.3. The sites are using the following custom light and dark UO libraries themes:

- [Light Theme (v1.3.0)](https://github.com/uoregon-libraries/UO-Library-Omeka-S-Theme)
- [Dark Theme (v1.3.2)](https://github.com/uoregon-libraries/UO-Library-Omeka-S-Theme-Dark)

## Repository Layout

```
Dockerfile              Image definition for every site: a shared "base" stage
                        (PHP, Apache, Omeka S) plus one small stage per site
docker/                 Scripts and PHP config baked into the base stage
sites/SITE/
  compose.yaml          Compose config; works as-is for local development
  compose.prod.yaml     Production additions (see "Production" below)
  .env.example          Settings that can be overridden in a .env file
  modules, themes       URLs of the add-on zips installed into the site's image
  README.md             Site settings that live in the database (footers, CSS)
```

Everything a site needs (Omeka, modules, themes, Apache config) is built into
its image. The only things mounted at runtime are the uploaded files and the
database's data.

These instructions use `docker compose`, but podman-compose works the same way.
The old Python `docker-compose` (v1) is not supported, since it doesn't look for
`compose.yaml`.

## Local Development

```bash
cd sites/mellon     # or sites/red
docker compose up --build
```

Mellon is then at http://localhost:8001 and Red at http://localhost:8000. You
don't need a `.env` file; copy `.env.example` to `.env` only if you want to
change something, like the port.

Building a site builds the shared base stage first, or reuses it from cache, so
there is no separate base image to build or tag. Run `docker compose up --build`
again whenever the `Dockerfile`, `docker/`, or the site's `modules` and `themes`
change.

Commands below are run from the site's directory, e.g. `sites/mellon`.

### Database Setup

To load a SQL dump of the production database, start the containers and run:

```bash
docker compose exec -T db sh -c 'exec mysql -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE"' < /path/to/dump.sql
```

**This overwrites every table in the dump.** To instead start completely fresh,
`docker compose down -v` removes the database **and** the uploaded files.

Afterwards, migrate the database if Omeka asks you to, and go to the localhost
version of the site where you should see a log-in screen.

### User Setup

If you are not already set up as an administrator for the instance, manually
add yourself to the sql dump file used in the previous step. The other admins
are defined in the `user` table.

To set a password on an existing account, generate a hash and store it in the
user's `password_hash` column:

```bash
docker compose exec omeka php -r 'echo password_hash("NEW PASSWORD", PASSWORD_DEFAULT), "\n";'
docker compose exec db sh -c 'exec mysql -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE"'
```

```sql
UPDATE user SET password_hash = 'HASH' WHERE email = 'you@uoregon.edu';
```

### Uploaded Files

Uploaded files are kept in the `files` volume. To work with a copy of
production's files instead, put them in a `files` directory in the site's
directory and create a `compose.override.yaml` (it's ignored by git, so it's a
good place for any local-only changes):

```yaml
services:
  omeka:
    volumes:
      - ./files:/var/www/html/files
```

The container's `www-data` user (uid 33) needs to be able to write to that
directory: `sudo chown -R 33:33 files` with Docker, or
`podman unshare chown -R 33:33 files` with rootless podman.

## Production

Production runs the same `compose.yaml`, with `compose.prod.yaml` layered on
top. That file keeps uploaded files and database data in existing host
directories by pointing the `files` and `db` named volumes at them. The
services' own `volumes` are never overridden, so they are configured the same
way everywhere.

One-time setup, in the site's directory on the server:

```bash
ln -s compose.prod.yaml compose.override.yaml
cp .env.example .env
```

Then edit `.env`: set real database credentials, `HOST_PORT`, and the two host
directories, `FILES_LOCATION` and `DB_LOCATION`. Check the result with
`docker compose config`: the volumes at the bottom should list those
directories as their `device`. If either variable is missing, Compose refuses
to start rather than quietly using empty volumes.

To deploy changes:

```bash
git pull
docker compose up -d --build
```

### Migrating From the Old Setup

The old setup (separately built and tagged images, `docker-compose.yml` plus a
hand-written `docker-compose.override.yml`) needs a one-time switch on each
production server:

1. **Before pulling**, note where the running containers keep their data. Run
   `docker inspect CONTAINER --format '{{json .Mounts}}'` for the Omeka and db
   containers, and note the host paths mounted at `/var/www/html/files` and
   `/var/lib/mysql`.
2. `git pull`, then move the old `docker-compose.override.yml` out of the way
   (podman-compose would otherwise load it along with the new files).
3. Do the one-time setup above, using the paths from step 1 for
   `FILES_LOCATION` and `DB_LOCATION`. Keep the existing `DB_*` and
   `HOST_PORT` values in `.env`; `DB_BACKUP` and `SITE_BACKUP` are no longer
   used and can be removed.
4. Build while the old site is still running, then swap it out:
   ```bash
   docker compose build
   docker compose up -d --remove-orphans
   ```
   `--remove-orphans` is needed once, because the app's service was renamed
   from `omeka-s-SITE` to `omeka`, and the old container still holds the port.
5. If the server uses podman-compose's systemd integration, re-run
   `podman-compose systemd -a register` so the unit picks up the new files.

If step 1 shows the database in a named volume rather than a host directory,
don't symlink `compose.prod.yaml`. Instead, write a `compose.override.yaml`
that points `db` at the existing volume:

```yaml
volumes:
  db:
    external: true
    name: EXISTING_VOLUME_NAME
```

## Adding a Site

1. Copy `sites/red` to `sites/NEW_SITE` and edit its `modules` and `themes`.
2. Add a stage for it at the bottom of the `Dockerfile`, modeled on `red`'s.
3. In the new `compose.yaml`, change `target`, `image`, and the default
   `HOST_PORT`.

## Static Files

In production, both instances of Omeka serve static files from a mounted
directory on a UO server. That directory is `FILES_LOCATION` in production's
`.env`.

## Other Config

### Footers

The footer content for the dark theme is hard-coded into the theme, so if any other site wants to use the dark theme, that will have to change.

As for the light theme, each site has it’s own footer content settings that can be modified in the theme settings in the admin interface. This content is stored in the `README`s in each direct subdirectory of `sites`.

### CSS Editor Module

Some additional inline css is defined in the CSS Editor module in the admin interface. This is only relevant for Red and can be found in `sites/red/README.md`.

### Startup Scripts

On startup, the container writes Omeka's `config/database.ini` from the `DB_*`
environment variables, starts sendmail, and runs any `*.sh` scripts found in
`/docker-entrypoint/` before starting Apache. A failing script there does
**not** stop the container from starting.

## For Future Upgrades

In the case of a future upgrade, the following things will need to happen:

- Upgrade the PHP version in the `FROM` line of the `Dockerfile`. Omeka S 3.x
  doesn't support PHP past 8.1, so newer PHP requires Omeka S 4.x. Moving off
  Debian bullseye also means removing the `archive.debian.org` workaround.
- Upgrade Omeka S by changing `OMEKA_VERSION` in the `Dockerfile`
- Update any dependencies in the `Dockerfile` that may have changed in the new php version
- Update dark and light themes in their respective repositories to be compatible with new Omeka version
- Update theme versions in `sites/INSTANCE/themes`
- Update module versions in `sites/INSTANCE/modules` (https://omeka.org/s/modules is a good resource for this)
