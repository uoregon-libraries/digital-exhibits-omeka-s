#!/usr/bin/env bash

# Install Omeka modules
if [[ -n "${MODULE_FILE}" ]] && [[ -f "${MODULE_FILE}" ]]; then
  while read m; do
    echo "$0: Installing module: $m"
    curl -sSL "$m" -o "module.zip"
    unzip -qn module.zip -d ${OMEKA_PATH}/modules/
    rm module.zip
  done < ${MODULE_FILE}
fi
