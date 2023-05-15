# UO Libraries Omeka-S Digital Exhibits

The University of Oregon has two instances of Omeka-S: Red and Mellon.

Red houses the 'Red Thread' digital exhibit at https://redthread.uoregon.edu.

Mellon hosts 'Tekagami and Kyōgire', 'The Artful Fabric of Collecting', 'Windows to the Ainu World', 'Yokai Senjafuda', and other under-construction exhibits at https://glam.uoregon.edu.

These two instances are separate because of some custom features that were built into Red Thread.

Both instances are running Omeka-S v3.2.3. The sites are using the following custom light and dark UO libraries themes:

- [Light Theme (v1.3.0)](https://github.com/uoregon-libraries/UO-Library-Omeka-S-Theme)
- [Dark Theme (v1.3.2)](https://github.com/uoregon-libraries/UO-Library-Omeka-S-Theme-Dark)

## Development

### Building image

The first step in running both Mellon and Red is building the base image defined in the `base-image` directory. The Omeka version number is also used as the `APP_VERSION` number in `base-image/env_make` and can be used to tag the docker image.
To build the image, run

```bash
make
```

in the `base-image` directory. And optionally, to tag as the latest version, or with the specific Omeka version, run

```bash
make tag-latest
```

and/or

```bash
make tag-version
```

Then, to build the specific instance of Omeka, cd into the corresponding subdirectory of the `sites` directory, and repeat the make process there.

You will also need to create a .env file, and docker-compose.override to set up the db container.

Use `docker-compose up -d` to start the specific container.

### Database Setup

You will need a sql dump of the production image which you will need to copy into the db container and set up. **Be careful as this will remove any existing database in the container.** The steps are as follows

```bash
docker cp SQL_DUMP_FILE.sql DB_CONTAINER_ID:/tmp
docker-compose exec db bash
```

```bash
mysql -u DB_USER -p
```

```sql
drop database DB_NAME;
create database DB_NAME;
quit
```

```bash
mysql -u DB_USER -p DB_NAME < /tmp/SQL_DUMP_FILE.sql
exit
```

Afterwards, migrate the database, and go to the localhost version of the site where you should see a log-in screen.

### User Setup

If you are not already set up as an administrator for the instance, manually add yourself to the sql dump file used in the previous step. Find where the other admins are defined.

The password will need to be hashed using the default php `password_hash()` function (for php 7.1).

## Static Files

In production, both instances of Omeka serve static files from a mounted directory on a UO server. The location of this directory will be specified as a volume in a docker-compose.override file.

In development, the containers will serve static images from a local directory. Again, this will be reflected in the docker-compose override. The container will need to have write privileges to this directory in order to install Omeka-S correctly.

## Other Config

Some additional config beyond what’s already in the repository.

### Footers

The footer content for the dark theme is hard-coded into the theme, so if any other site wants to use the dark theme, that will have to change.

As for the light theme, each site has it’s own footer content settings that can be modified in the theme settings in the admin interface. This content is stored in the `README`s in each direct subdirectory of `sites`.

### CSS Editor Module

Some additional inline css is defined in the CSS Editor module in the admin interface. This is only relevant for Red and can be found in `sites/red/README.md`.

## For Future Upgrades

In the case of a future upgrade, the following things will need to happen:

- Upgrade php version in `base-image/Dockerfile`
- Upgrade Omeka S version in `base-image/Dockerfile`
- Update any dependencies in `base-image/Dockerfile` that may have changed in the new php version
- Update dark and light themes in their respective repositories to be compatible with new Omeka version
- Update theme versions in `sites/INSTANCE/themes`
- Update module versions in `sites/INSTANCE/modules` (https://omeka.org/s/modules is a good resource for this)
- Update `APP_VERSION` in the different `env_make` files
