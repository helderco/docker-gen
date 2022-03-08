FROM nginxproxy/docker-gen:latest

RUN apk --update add bash curl jq && rm -rf /var/cache/apk/*

COPY docker-label-sighup /usr/bin/docker-label-sighup
