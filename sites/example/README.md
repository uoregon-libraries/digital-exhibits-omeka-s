# Setup
Dev and Prod follow the same basic setup instructions. Specifics may differ based on your environments.
- Install [Docker](https://www.docker.com/get-started)
- Copy example site to a new site folder
-
- Copy .env.example to .env
- Fill out env vars as you see fit
- Copy modules.example and themes.example to modules and themes respectively
- Fill out modules and themes as you see fit
- Copy docker-compose.override.example.yml to docker-compose.override.yml
- Fill in volumes, env vars, and services as you see fit.
  - A minimal dev setup is provided
  - A minimal prod setup would involve:
    - Delete the db service
    - Point your DB env vars to a persistent DB
    - Uncomment and setup the files volume for persistent storage
- `docker-compose up -d`

# Configuration
## Environment
The environment contains a lot of the base config. Reference the table below for env vars definitions. Many common values can be defined in a .env file. More configuration may be needed for other values.

| Var | Config |
| --- | ------ |
| $DB_USER | Omeka database username |
| $DB_PASS | Omeka database password |
| $DB_NAME | Omeka database name |
| $DB_HOST | Omeka database host |
| $DB_PORT | Omeka database port |
| $DB_UNIX_SOCKET | Omeka database socket |
| $DB_LOG_PATH | Omeka path to log database activity |
| $DB_BACKUP | File path to database backup to import from. A database import will only occur if no database of $DB_NAME exists on $DB_HOST. On an interactive terminal, startup will ask if you want to dump before importing, otherwise no dump will occur. |
| $HOST_PORT | Port to expose container on |

## Init
The initialization process does the following on omeka-s service startup:
- Set Omeka-s file system permissions
- Setup Omeka database.ini file based on env vars
- Import $DB_BACKUP if setup
- Run additional scripts
  - You can define additional \*.sh scripts at `/docker-entrypoint/` to run on startup.
  - A failed script here will **NOT** fail service startup.
- Begin Apache
