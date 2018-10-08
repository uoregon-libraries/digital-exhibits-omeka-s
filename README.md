# Setup
Dev and Prod follow the same basic setup instructions. Specifics may differ based on your environments.
- Install [Docker](https://www.docker.com/get-started)
- Copy .env.example to .env
- Fill out env vars as you see fit
- Copy docker-compose.override.example.yml to docker-compose.override.yml
- Fill in volumes, env vars, and services as you see fit.
  - A minimal dev setup is provided
  - A minimal prod setup would involve:
    - Deleting the db service
    - Defining modules volume and deleting db dump volume
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
| $SITE_BACKUP | File path to compressed Omeka webroot. A site backup will only be used if the .htaccess file does not exist at $OMEKA_PATH. If no .htaccess exists and $OMEKA_PATH and no $DB_BACKUP is defined, Omeka will be downloaded from GitHub. |
| $OMEKA_PATH | The path to Omeka webroot |
| $OMEKA_VER | Version of Omeka to download if $SITE_BACKUP is not set. Include the leading 'v'. If no value provided, init will grab the latest version |
| $MODULE_FILE | File path to a line separated list of modules to download and install. |
| $LOG_LEVEL | Apache log level to use |

## Init
The initialization process does the following on omeka-s service startup:
- Download Omeka-s if no .htaccess exists at $OMEKA_PATH. Use $SITE_BACKUP or $OMEKA_VER or latest GitHub release as set.
- Setup Omeka database.ini file.
- Import $DB_BACKUP if setup
- Configure Apache2 to write logs to stdout/docker logs
- Run additional scripts
  - You can define additional \*.sh scripts at `/docker-entrypoint/` to run on startup.
  - A failed script here will **NOT** fail service startup.
- Begin LAMP stack
