#!/usr/bin/env bash
OMEKA_PATH=${OMEKA_PATH:-"/var/www/html"}
shopt -s nullglob dotglob

# Premptively start mysql daemon
/usr/bin/mysqld_safe --timezone=${DATE_TIMEZONE}&



### Install Omeka-S ###
# Install if Omeka path is empty
if [[ ! -f "${OMEKA_PATH}/.htaccess" ]]; then
  echo "Installing Omeka-s"
  # Install from backup if exists
  if [[ -n "${SITE_BACKUP}" ]] && [[ -f "${SITE_BACKUP}" ]]; then
    case $(file --mime-type -b "${SITE_BACKUP}") in
        application/x-gzip)
          tar -xzvf ${SITE_BACKUP} -C ${OMEKA_PATH}
          ;;
        application/zip)
          unzip -q ${SITE_BACKUP} -d ${OMEKA_PATH}
          ;;
        *)
          echo "${SITE_BACKUP} uses an unknown backup compression method"
          exit 0
          ;;
    esac
    echo "Installed from backup: ${SITE_BACKUP}"
  # Otherwise install fresh
  else
    if [[ -n "${OMEKA_VER}" ]]; then
      tag=${OMEKA_VER}
    else
      tag=$(curl --silent https://api.github.com/repos/omeka/omeka-s/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    fi
    url=https://github.com/omeka/omeka-s/releases/download/$tag/omeka-s-${tag:1}.zip
    echo "Downloading Omeka-S from: ${url}"
    curl -sSL ${url} -o omeka.zip
    unzip -qn omeka.zip -d ${OMEKA_PATH}
    mv ${OMEKA_PATH}/omeka-s/* ${OMEKA_PATH}
    rm ${OMEKA_PATH}/omeka-s -rf
    echo "Installed official release"
  fi
  rm ${OMEKA_PATH}/index.html
fi
# Install Omeka modules
if [[ -n "${MODULE_FILE}" ]] && [[ -f "${MODULE_FILE}" ]]; then
  while read m; do
    echo "Installing module: $m"
    curl -sSL "$m" -o "module.zip"
    unzip -qn module.zip -d ${OMEKA_PATH}/modules/
    rm module.zip
  done < ${MODULE_FILE}
fi
# Install Omeka themes
if [[ -n "${THEME_FILE}" ]] && [[ -f "${THEME_FILE}" ]]; then
  while read t; do
    echo "Installing theme: $t"
    curl -sSL "$t" -o "theme.zip"
    unzip -qn module.zip -d ${OMEKA_PATH}/themes/
    rm theme.zip
  done < ${THEME_FILE}
fi
chown -R www-data:www-data ${OMEKA_PATH}



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
  echo "Attempting DB Restore"
  # Test our connection to MySQL server and fail out if we can't connect
  database=$(mysql --user=${DB_USER} --password=${DB_PASS} --host=${DB_HOST} -sNe "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME='${DB_NAME}'")
  [[ $? = 0 ]] || exit $?

  # Prompt user if they want to dump and import, default to no dump
  CHOICE="N"
  [[ -t 0 ]] && [[ -n $database ]] && read -p "Dump database ${DB_NAME} and import backup ${DB_BACKUP} (Y/*)[N] " CHOICE
  if [[ ${CHOICE} =~ ^[Yy].* ]]; then
    echo "Dumping Database..."
    mysql --user=${DB_USER} --password=${DB_PASS} --host=${DB_HOST} --execute="DROP DATABASE ${DB_NAME};"
    database=""
  fi

  # Create DB and import if no DB exists
  if [[ -z $database ]]; then
    echo "Importing Database..."
    mysql --user=${DB_USER} --password=${DB_PASS} --host=${DB_HOST} --execute="CREATE DATABASE IF NOT EXISTS ${DB_NAME};"
    mysql --user=${DB_USER} --password=${DB_PASS} --host=${DB_HOST} --database=${DB_NAME} < ${DB_BACKUP}
  fi
fi

### Apache2 Config ###
# Enable proper Apache logging
sed -ri \
    -e 's!^(\s*CustomLog)\s+\S+!\1 /proc/1/fd/1!g' \
    -e 's!^(\s*TransferLog)\s+\S+!\1 /proc/1/fd/1!g' \
    -e 's!^(\s*ErrorLog)\s+\S+!\1 /proc/1/fd/2!g' \
    /etc/apache2/apache2.conf /etc/apache2/*-enabled/*.conf



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
