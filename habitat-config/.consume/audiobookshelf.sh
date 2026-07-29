#!/usr/bin/env bash

set -euo pipefail

SOURCE_PATH="$1"; [ -d "$SOURCE_PATH" ] || { echo "'$SOURCE_PATH' not found."; exit 1; }
TARGET_PATH="/habitat-config/target/audiobookshelf"

echo "Cleaning previous configuration at '$TARGET_PATH'"
rm -rf "${TARGET_PATH:?}/"{*,.*} &>/dev/null
echo "Copying new configuration to '$TARGET_PATH'"
cp -rp "$SOURCE_PATH/." "$TARGET_PATH/"
exit 0