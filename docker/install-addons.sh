#!/usr/bin/env bash
#
# Usage: install-addons.sh <modules|themes> <list-file>
#
# Installs each Omeka add-on listed in <list-file> into $OMEKA_PATH/modules or
# $OMEKA_PATH/themes. Each line is the URL of a zip file, optionally followed by
# ";<unzipped-dir>;<new-dir>" to rename the directory the zip creates.
#
# Any failed download fails the whole script, and therefore the image build.
set -euo pipefail

type=$1
list=$2
dest="${OMEKA_PATH}/${type}"

# The "|| [[ ... ]]" keeps the last line if the file has no trailing newline
while IFS=';' read -ra m || [[ -n "${m[0]:-}" ]]; do
  [[ -z "${m[0]:-}" ]] && continue

  echo "$0: Installing ${type%s}: ${m[0]}"
  curl -fsSL "${m[0]}" -o /tmp/addon.zip
  unzip -qn /tmp/addon.zip -d "$dest"
  rm /tmp/addon.zip
  if [[ -n "${m[1]:-}" ]] && [[ -n "${m[2]:-}" ]]; then
    echo "$0: Renaming ${type%s} directory '${m[1]}': to '${m[2]}'"
    mv "$dest/${m[1]}" "$dest/${m[2]}"
  fi
done < "$list"
