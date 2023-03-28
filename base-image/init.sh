#!/usr/bin/env bash
OMEKA_PATH=${OMEKA_PATH:-"/var/www/html"}

### Make sure Apache permissions are set ###
#TODO: fix this line (possibly needs -print after the -o), or permanently remove?
#find ${OMEKA_PATH} -not -user www-data -name files -prune -o | xargs chown www-data:www-data



### Generate Omeka-S Database Config ###
DBUSER=${DB_USER:-omeka}
DBPASS=${DB_PASS:-omeka}
DBNAME=${DB_NAME:-omeka}
DBHOST=${DB_HOST:-localhost}

echo "user = ${DB_USER}" > "${OMEKA_PATH}/config/database.ini"
echo "password = ${DB_PASS}" >> "${OMEKA_PATH}/config/database.ini"
echo "dbname = ${DB_NAME}" >> "${OMEKA_PATH}/config/database.ini"
echo "host = ${DB_HOST}" >> "${OMEKA_PATH}/config/database.ini"
if [ -n "${DB_PORT}" ]; then
  echo "port = ${DB_PORT}" >> "${OMEKA_PATH}/config/database.ini"
fi
if [ -n "${DB_UNIX_SOCKET}" ]; then
  echo "unix_socket = ${DB_UNIX_SOCKET}" >> "${OMEKA_PATH}/config/database.ini"
fi
if [ -n "${DB_LOG_PATH}" ]; then
  echo "log_path = ${DB_LOG_PATH}" >> "${OMEKA_PATH}/config/database.ini"
fi



### Import DB Backup ###
# Redeploy DB if backup is set and database isn't present
if [[ -n "${DB_BACKUP}" ]] && [[ -f "${DB_BACKUP}" ]]; then
  echo "$0: Attempting DB Restore"
  # Test our connection to MySQL server and fail out if we can't connect
  database=$(mysql --user=${DB_USER} --password=${DB_PASS} --host=${DB_HOST} -sNe "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME='${DB_NAME}'")
  [[ $? = 0 ]] || exit $?

  # Prompt user if they want to dump and import, default to no dump
  CHOICE="N"
  [[ -t 0 ]] && [[ -n $database ]] && read -p "Dump database ${DB_NAME} and import backup ${DB_BACKUP} (Y/*)[N] " CHOICE
  if [[ ${CHOICE} =~ ^[Yy].* ]]; then
    echo "$0: Dumping Database..."
    mysql --user=${DB_USER} --password=${DB_PASS} --host=${DB_HOST} --execute="DROP DATABASE ${DB_NAME};"
    database=""
  fi

  # Create DB and import if no DB exists
  if [[ -z $database ]]; then
    echo "$0: Importing Database..."
    mysql --user=${DB_USER} --password=${DB_PASS} --host=${DB_HOST} --execute="CREATE DATABASE IF NOT EXISTS ${DB_NAME};"
    mysql --user=${DB_USER} --password=${DB_PASS} --host=${DB_HOST} --database=${DB_NAME} < ${DB_BACKUP}
  fi
fi



### Configure sendmail
echo "127.0.0.1 $(hostname) localhost localhost.localdomain" >> /etc/hosts
service sendmail restart



### Run Additional .sh Scripts ###
for f in /docker-entrypoint/*; do
	case "$f" in
		*.sh)	echo "$0: running $f"; . "$f" ;;
		*)		echo "$0: ignoring $f" ;;
	esac
	echo
done



### Run Docker CMD ###
exec "$@"
