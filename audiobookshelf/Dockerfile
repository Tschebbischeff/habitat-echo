FROM ghcr.io/advplyr/audiobookshelf:latest

RUN apk add --no-cache curl envsubst patch jq

COPY ./patches /habitat-patches
RUN patch "/app/server/auth/OidcAuthStrategy.js" <"/habitat-patches/OidcAuthStrategy.js.patch"
RUN rm -rf /habitat-patches

COPY ./entrypoint-hook.sh /entrypoint-hook.sh
RUN chmod +x /entrypoint-hook.sh

ENTRYPOINT ["/entrypoint-hook.sh"]
CMD	[ "tini", "--", "node", "index.js" ]