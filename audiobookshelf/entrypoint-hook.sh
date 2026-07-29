#!/bin/sh

# Extract secrets to environment variables
ROOT_PASSWORD="$AUDIOBOOKSHELF_ROOT_PASSWORD"
[ -f "$AUDIOBOOKSHELF_ROOT_PASSWORD_FILE" ] && ROOT_PASSWORD="$(cat "$AUDIOBOOKSHELF_ROOT_PASSWORD_FILE")"
[ -n "$ROOT_PASSWORD" ] || { echo "No admin password set. Please set either AUDIOBOOKSHELF_ROOT_PASSWORD or AUDIOBOOKSHELF_ROOT_PASSWORD_FILE"; exit 1; }

# Start server on different port so we can run the initialization, provisioning, etc.
{ [ "$PORT" -ne "13378" ] && TEMP_PORT="13378"; } || TEMP_PORT="13379"
echo "Starting temporary server on port $TEMP_PORT for initialization and provisioning..."
(
    export PORT="$TEMP_PORT"
    exec "$@"
) &
SERVER_PID="$!"
echo "Waiting for temporary server to be available..."
while ! curl -XGET -sfo /dev/null "http://127.0.0.1:$TEMP_PORT/healthcheck"; do sleep 5; done
echo "Temporary server is online, continuing."

# First initialization
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
                "password": "'"$ROOT_PASSWORD"'"
            }
        }' \
        "http://127.0.0.1:$TEMP_PORT/init"
    then
        echo "Successfully initialized 'root' user."
    else
        echo "Could not initialize 'root' user. Fatal! Can't continue."
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
            "password": "'"$ROOT_PASSWORD"'"
        }' \
        "http://localhost:$TEMP_PORT/login"
)"
TOKEN="$(node -e "console.log(JSON.parse(process.argv[1]).user.accessToken)" "$response" 2>/dev/null)"
[ -n "$TOKEN" ] || { echo "Could not log in as root user."; exit 3; }

# Provisioning
# TODO

# End the session
echo "Logging out..."
curl -XPOST -so /dev/null -b "$CURL_COOKIEJAR" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d '{
        "socketId": null
    }' \
    "http://localhost:$TEMP_PORT/logout"
rm "$CURL_COOKIEJAR"

# Shut down temporary server and run the real thing
echo "Shutting down temporary server..."
kill -15 "$SERVER_PID"
wait "$SERVER_PID"

echo "Entrypoint hook done. Starting original entrypoint..."
exec "$@"