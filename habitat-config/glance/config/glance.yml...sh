#!/usr/bin/env bash

set -euo pipefail

TARGET_FILE="$1"
TARGET_FILE_CONTENT="$(cat "$TARGET_FILE")"


# ### Init

SOURCE_FILE_APP_CATEGORY="$(mktemp)"
SOURCE_FILE_APP_SITE="$(mktemp)"
SOURCE_FILE_DEV_REPOSITORIES="$(mktemp)"

APP_PAGE_NAME="Apps"
APP_PAGE_CATEGORY_NAME="Apps"
DEV_PAGE_NAME="Development"

cat >"$SOURCE_FILE_APP_CATEGORY" <<EOF
type: monitor
cache: 10s
title: "$APP_PAGE_CATEGORY_NAME"
sites: []
EOF

cat >"$SOURCE_FILE_APP_SITE" <<'EOF'
- title: Audiobookshelf
  url: https://audiobookshelf.${APP_HOST}
  check-url: http://${APP_NAME_HOST}_audiobookshelf:80
  icon: /assets/icons/di/audiobookshelf.svg
EOF

cat >"$SOURCE_FILE_DEV_REPOSITORIES" <<'EOF'
- advplyr/audiobookshelf
EOF


# ### Add to "Apps" page

YQ_SEARCH_CATEGORY='(
  .pages[] | select(.name == "'"$APP_PAGE_NAME"'") |
  .columns[0].widgets[] | select(.type == "split-column") |
  .widgets
)[] | select(.title == "'"$APP_PAGE_CATEGORY_NAME"'")'
YQ_ADD_CATEGORY='
  (
    .pages[] | select(.name == "'"$APP_PAGE_NAME"'") |
    .columns[0].widgets[] | select(.type == "split-column") |
    .widgets
  ) |= [load("'"$SOURCE_FILE_APP_CATEGORY"'")] + .
'
YQ_ADD_SITE='
  (
    .pages[] | select(.name == "'"$APP_PAGE_NAME"'") |
    .columns[0].widgets[] | select(.type == "split-column") |
    .widgets[] | select(.title == "'"$APP_PAGE_CATEGORY_NAME"'") | .sites
  ) += load("'"$SOURCE_FILE_APP_SITE"'")
'

if [ -z "$(yq eval "$YQ_SEARCH_CATEGORY" <<<"$TARGET_FILE_CONTENT")" ]; then
  # shellcheck disable=2016 # Variables are internal to yq expression
  TARGET_FILE_CONTENT="$(yq eval "$YQ_ADD_CATEGORY" <<<"$TARGET_FILE_CONTENT")"
fi

# shellcheck disable=2016 # Variables are internal to yq expression
TARGET_FILE_CONTENT="$(yq eval "$YQ_ADD_SITE" <<<"$TARGET_FILE_CONTENT")"


# ### Add to "Development" page

YQ_ADD_REPOSITORIES='
  (
    .pages[] | select(.name == "'"$DEV_PAGE_NAME"'").columns[0].widgets[] |
    select(.type == "releases") | .repositories
  ) += load("'"$SOURCE_FILE_DEV_REPOSITORIES"'")
'

# shellcheck disable=2016 # Variables are internal to yq expression
TARGET_FILE_CONTENT="$(yq eval "$YQ_ADD_REPOSITORIES" <<<"$TARGET_FILE_CONTENT")"


# ### Clean Up, Print Result and Exit
rm "$SOURCE_FILE_APP_CATEGORY" "$SOURCE_FILE_APP_SITE" "$SOURCE_FILE_DEV_REPOSITORIES"

echo "$TARGET_FILE_CONTENT"
exit 0