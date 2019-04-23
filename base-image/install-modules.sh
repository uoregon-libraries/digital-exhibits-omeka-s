#!/usr/bin/env bash

# Install Omeka modules
if [[ -n "${MODULE_FILE}" ]] && [[ -f "${MODULE_FILE}" ]]; then
  while IFS=';' read -ra m; do
    echo "$0: Installing module: ${m[0]}"
    curl -sSL "${m[0]}" -o "module.zip"
    unzip -qn module.zip -d ${OMEKA_PATH}/modules/
    rm module.zip
    if [[ ! -z ${m[1]} ]] && [[ ! -z ${m[2]} ]]; then
      echo "$0: Renaming module directory '${m[1]}': to '${m[2]}'"
      mv ${OMEKA_PATH}/modules/${m[1]} ${OMEKA_PATH}/modules/${m[2]}
    fi
  done < ${MODULE_FILE}
fi
