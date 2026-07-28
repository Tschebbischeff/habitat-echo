#!/usr/bin/env bash

SOURCE_PATH="$1"

export AUDIOBOOKSHELF_OAUTH_CLIENT_ID="$(cat "/run/secrets/AUDIOBOOKSHELF_OAUTH_CLIENT_ID")"
export AUDIOBOOKSHELF_OAUTH_CLIENT_SECRET_HASHED_PBKDF2="$(cat "/run/secrets/AUDIOBOOKSHELF_OAUTH_CLIENT_SECRET_HASHED_PBKDF2")"

find "$SOURCE_PATH" -type f -name '*.yml' | while read -r filePath; do
    if envsubst <"$filePath" >"$filePath.envsubst"; then
        mv "$filePath.envsubst" "$filePath"
    else
        rm "$filePath.envsubst" &>/dev/null
    fi
done