FROM ghcr.io/advplyr/audiobookshelf:latest

RUN apk add --no-cache curl

COPY ./entrypoint-hook.sh /entrypoint-hook.sh
RUN chmod +x /entrypoint-hook.sh

ENTRYPOINT ["/entrypoint-hook.sh"]
CMD	[ "tini", "--", "node", "index.js" ]