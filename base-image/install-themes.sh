#!/usr/bin/env bash

# Install Omeka themes
if [[ -n "${THEME_FILE}" ]] && [[ -f "${THEME_FILE}" ]]; then
  while IFS=';' read -ra m; do
    echo "$0: Installing theme: ${m[0]}"
    curl -sSL "${m[0]}" -o "theme.zip"
    unzip -qn theme.zip -d ${OMEKA_PATH}/themes/
    rm theme.zip
    if [[ ! -z ${m[1]} ]] && [[ ! -z ${m[2]} ]]; then
      echo "$0: Renaming theme directory '${m[1]}': to '${m[2]}'"
      mv ${OMEKA_PATH}/themes/${m[1]} ${OMEKA_PATH}/themes/${m[2]}
    fi
  done < ${THEME_FILE}
fi
