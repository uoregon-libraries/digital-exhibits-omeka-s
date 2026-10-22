#!/usr/bin/env bash
#
# Container entrypoint: writes Omeka's database config from the environment,
# starts sendmail so PHP can send email, runs any extra startup scripts, then
# hands off to the container's command (Apache).
OMEKA_PATH=${OMEKA_PATH:-"/var/www/html"}

### Generate Omeka-S Database Config ###
{
  echo "user = ${DB_USER:-omeka}"
  echo "password = ${DB_PASS:-omeka}"
  echo "dbname = ${DB_NAME:-omeka}"
  echo "host = ${DB_HOST:-localhost}"
  if [ -n "${DB_PORT}" ]; then
    echo "port = ${DB_PORT}"
  fi
  if [ -n "${DB_UNIX_SOCKET}" ]; then
    echo "unix_socket = ${DB_UNIX_SOCKET}"
  fi
  if [ -n "${DB_LOG_PATH}" ]; then
    echo "log_path = ${DB_LOG_PATH}"
  fi
} > "${OMEKA_PATH}/config/database.ini"



### Configure sendmail
echo "127.0.0.1 $(hostname) localhost localhost.localdomain" >> /etc/hosts
service sendmail restart



### Run Additional .sh Scripts ###
for f in /docker-entrypoint/*; do
	[ -e "$f" ] || continue
	case "$f" in
		*.sh)	echo "$0: running $f"; . "$f" ;;
		*)		echo "$0: ignoring $f" ;;
	esac
	echo
done



### Run Docker CMD ###
exec "$@"
