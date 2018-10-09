#!/usr/bin/env bash

# Install Omeka themes
if [[ -n "${THEME_FILE}" ]] && [[ -f "${THEME_FILE}" ]]; then
  while read t; do
    echo "Installing theme: $t"
    curl -sSL "$t" -o "theme.zip"
    unzip -qn theme.zip -d ${OMEKA_PATH}/themes/
    rm theme.zip
  done < ${THEME_FILE}
fi
