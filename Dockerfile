FROM jwilder/docker-gen:latest

RUN apk --update add bash curl jq && rm -rf /var/cache/apk/*

ADD https://raw.githubusercontent.com/jwilder/nginx-proxy/master/nginx.tmpl /etc/docker-gen/templates/nginx.tmpl

COPY docker-label-sighup /usr/bin/docker-label-sighup
