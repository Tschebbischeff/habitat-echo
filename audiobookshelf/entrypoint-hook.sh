#!/bin/sh

ADMIN_PASSWORD="$AUDIOBOOKSHELF_ADMIN_PASSWORD"
[ -f "$AUDIOBOOKSHELF_ADMIN_PASSWORD_FILE" ] && ADMIN_PASSWORD="$(cat "$AUDIOBOOKSHELF_ADMIN_PASSWORD_FILE")"

# wget --quiet --method=POST \
#     --header="Content-Type: application/json" \
#     --body-data='
#         {
#             "newRoot": {
#                 "username": "admin",
#                 "password": "'"$ADMIN_PASSWORD"'"
#             }
#         }
#     ' \
#     'http://127.0.0.1:80/init'

exec "$@"