#!/bin/sh

# Extract secrets to environment variables; Apply defaults to undefined environment variables
ABS_ROOT_PASSWORD="${ABS_ROOT_PASSWORD:-}"
[ -f "$ABS_ROOT_PASSWORD_FILE" ] && ABS_ROOT_PASSWORD="$(cat "$ABS_ROOT_PASSWORD_FILE")"
export ABS_OAUTH_CLIENT_ID="$ABS_OAUTH_CLIENT_ID"
[ -f "$ABS_OAUTH_CLIENT_ID_FILE" ] && export ABS_OAUTH_CLIENT_ID="$(cat "$ABS_OAUTH_CLIENT_ID_FILE")"
export ABS_OAUTH_CLIENT_SECRET="$ABS_OAUTH_CLIENT_SECRET"
[ -f "$ABS_OAUTH_CLIENT_SECRET_FILE" ] && export ABS_OAUTH_CLIENT_SECRET="$(cat "$ABS_OAUTH_CLIENT_SECRET_FILE")"
ABS_PROVISIONING_PATH="${ABS_PROVISIONING_PATH:-/provisioning}"

# Sanitize settings related env vars
[ -z "$ABS_SETTINGS_HOME_BOOKSHELF_VIEW" ] || { [ "$ABS_SETTINGS_HOME_BOOKSHELF_VIEW" = "true" ] && export ABS_SETTINGS_HOME_BOOKSHELF_VIEW="0"; } || export ABS_SETTINGS_HOME_BOOKSHELF_VIEW="1" # Somehow 1 means false for this field, let user use normal booleans though :^)
[ -z "$ABS_SETTINGS_BOOKSHELF_VIEW" ] || { [ "$ABS_SETTINGS_BOOKSHELF_VIEW" = "true" ] && export ABS_SETTINGS_BOOKSHELF_VIEW="0"; } || export ABS_SETTINGS_BOOKSHELF_VIEW="1" # Somehow 1 means false for this field, let user use normal booleans though :^)

# Early stop-condition checks on env vars
[ -n "$ABS_ROOT_PASSWORD" ] || { echo "No root password set. This environment variable is mandatory. Please set either ABS_ROOT_PASSWORD or ABS_ROOT_PASSWORD_FILE"; exit 1; }
[ -n "$ABS_OAUTH_CLIENT_ID" ] || { echo "No OAuth client ID set. This environment variable is mandatory. Please set either ABS_OAUTH_CLIENT_ID or ABS_OAUTH_CLIENT_ID_FILE"; exit 1; }
[ -n "$ABS_OAUTH_CLIENT_SECRET" ] || { echo "No OAuth client ID set. This environment variable is mandatory. Please set either ABS_OAUTH_CLIENT_SECRET or ABS_OAUTH_CLIENT_SECRET_FILE"; exit 1; }
[ -d "$ABS_PROVISIONING_PATH" ] || { echo "Provisioning dir '$ABS_PROVISIONING_PATH' does not exist."; exit 1; }
[ -f "$ABS_PROVISIONING_PATH/server_settings.jsone" ] || { echo "Provisioning dir '$ABS_PROVISIONING_PATH' contains no 'server_settings.jsone'."; exit 1; }
[ -f "$ABS_PROVISIONING_PATH/auth_settings.jsone" ] || { echo "Provisioning dir '$ABS_PROVISIONING_PATH' contains no 'auth_settings.jsone'."; exit 1; }

# Start server on different port so we can run the initialization, provisioning, etc. without fulfilling final healtchecks
{ [ "$PORT" -ne "13378" ] && TEMP_PORT="13378"; } || TEMP_PORT="13379"
echo "Starting temporary server on port $TEMP_PORT for initialization and provisioning..."
(
    export PORT="$TEMP_PORT"
    export TINI_SUBREAPER="_"
    exec "$@"
) &
TEMP_SERVER_PID="$!"
echo "Waiting for temporary server to be available..."
while ! curl -XGET -sfo /dev/null "http://127.0.0.1:$TEMP_PORT/healthcheck"; do sleep 5; done
echo "Temporary server is online, continuing."

# First initialization, REST API Documentation: https://api.audiobookshelf.org/
response="$(
    curl -XGET -s \
        -H "Content-Type: application/json" \
        "http://127.0.0.1:$TEMP_PORT/status"
)"
isInit="$(node -e "console.log(JSON.parse(process.argv[1]).isInit)" "$response" 2>/dev/null)"
if [ "$isInit" != "true" ]; then
    echo "Initializing 'root' user..."
    if curl -XPOST -sfo \
        -H "Content-Type: application/json" \
        -d '{
            "newRoot": {
                "username": "root",
                "password": "'"$ABS_ROOT_PASSWORD"'"
            }
        }' \
        "http://127.0.0.1:$TEMP_PORT/init"
    then
        echo "Successfully initialized 'root' user."
    else
        echo "Could not initialize 'root' user."
        exit 2
    fi
fi

# Start a user session as root
echo "Logging in as user 'root'..."
CURL_COOKIEJAR="$(mktemp)"
response="$(
    curl -XPOST -s -c "$CURL_COOKIEJAR" \
        -H "Content-Type: application/json" \
        -d '{
            "username": "root",
            "password": "'"$ABS_ROOT_PASSWORD"'"
        }' \
        "http://127.0.0.1:$TEMP_PORT/login"
)"
TOKEN="$(node -e "console.log(JSON.parse(process.argv[1]).user.accessToken)" "$response" 2>/dev/null)"
[ -n "$TOKEN" ] || { echo "Login as user 'root' failed."; exit 3; }

# ### Provisioning

# Server Settings
envsubst <"$ABS_PROVISIONING_PATH/server_settings.jsone" >"$ABS_PROVISIONING_PATH/server_settings.json"
# curl -XPATCH -sfo /dev/null -b "$CURL_COOKIEJAR" \
#     -H "Authorization: Bearer $TOKEN" \
#     -H "Content-Type: application/json" \
#     -d "$(envsubst <"$ABS_PROVISIONING_PATH/server_settings.jsone")" \
#     "http://127.0.0.1:$TEMP_PORT/api/settings" || {
#         echo "Could not set server settings, the server logs above may contain a hint as to why."
#         exit 4
#     }

# Auth Settings
envsubst <"$ABS_PROVISIONING_PATH/auth_settings.jsone" >"$ABS_PROVISIONING_PATH/auth_settings.json"
# curl -XPATCH -sfo /dev/null -b "$CURL_COOKIEJAR" \
#     -H "Authorization: Bearer $TOKEN" \
#     -H "Content-Type: application/json" \
#     -d "$(envsubst <"$ABS_PROVISIONING_PATH/auth_settings.jsone")" \
#     "http://127.0.0.1:$TEMP_PORT/api/auth-settings" || {
#         echo "Could not set auth settings, the server logs above may contain a hint as to why."
#         exit 4
#     }

# End the session
echo "Logging out..."
curl -XPOST -so /dev/null -b "$CURL_COOKIEJAR" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d '{
        "socketId": null
    }' \
    "http://127.0.0.1:$TEMP_PORT/logout"
rm "$CURL_COOKIEJAR"

# Shut down temporary server and run the real thing
echo "Shutting down temporary server..."
kill -15 "$TEMP_SERVER_PID"
wait "$TEMP_SERVER_PID"

echo "Entrypoint hook done. Starting original entrypoint..."
exec "$@"