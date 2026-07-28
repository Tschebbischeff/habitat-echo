#!/bin/sh

# wget --quiet --method=POST \
#     --header="Content-Type: application/json" \
#     --body-data='
#         {
#             "username": "admin",
#             "password":"admin"
#         }
#     ' \
#     http://localhost:80/init

exec "$@"