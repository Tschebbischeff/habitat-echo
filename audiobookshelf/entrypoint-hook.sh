#!/bin/sh

ADMIN_PASSWORD="$AUDIOBOOKSHELF_ADMIN_PASSWORD"
[ -f "$AUDIOBOOKSHELF_ADMIN_PASSWORD_FILE" ] && ADMIN_PASSWORD="$(cat "$AUDIOBOOKSHELF_ADMIN_PASSWORD_FILE")"
[ -n "$ADMIN_PASSWORD" ] || { echo "No admin password set. Please set either AUDIOBOOKSHELF_ADMIN_PASSWORD or AUDIOBOOKSHELF_ADMIN_PASSWORD_FILE"; exit 1; }

{ [ "$PORT" -ne "13378" ] && TEMP_PORT="13378"; } || TEMP_PORT="13379"
echo "Starting temporary server on port $TEMP_PORT for initialization and provisioning..."
(
    export PORT="$TEMP_PORT"
    exec "$@"
) &
SERVER_PID="$!"

echo "Waiting for temporary server to be available..."
while ! wget -q -O - --spider "http://127.0.0.1:$TEMP_PORT/healthcheck" 1>/dev/null 2>/dev/null; do sleep 5; done
echo "Temporary server is online, continuing."

if [ ! -f "$CONFIG_PATH/.habitat-init" ]; then
    echo "Initializing 'root' user..."
    if wget -q -O - \
        --header="Content-Type: application/json" \
        --post-data='{
            "newRoot": {
                "username": "root",
                "password": "'"$ADMIN_PASSWORD"'"
            }
        }' \
        "http://127.0.0.1:$TEMP_PORT/init" 1>/dev/null
    then
        echo "Successfully initialized 'root' user."
        touch "$CONFIG_PATH/.habitat-init"
    else
        echo "Could not initialize 'root' user. Fatal! Can't continue."
        exit 2
    fi
fi

echo "Logging in as user 'root'..."
RESPONSE="$(
    wget -q -O - \
        --header="Content-Type: application/json" \
        --post-data='{
            "username": "root",
            "password": "'"$ADMIN_PASSWORD"'"
        }' \
        "http://localhost:$TEMP_PORT/login"
)"
TOKEN="$(node -e "console.log(JSON.parse(process.argv[1]).user.token)" "$RESPONSE" 2>/dev/null)"

echo "Logging out..."
wget -q -O - \
    --header="Authorization: Bearer $TOKEN" \
    --header="Content-Type: application/json" \
    --post-data='{}' \
    "http://localhost:$TEMP_PORT/logout" 1>/dev/null

echo "Shutting down temporary server..."
kill -15 "$SERVER_PID"
wait "$SERVER_PID"

echo "Entrypoint hook done. Starting original entrypoint..."
exec "$@"