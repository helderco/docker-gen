# docker-gen with dynamic container names support

This is an enhancement to the [docker-gen](https://github.com/jwilder/docker-gen) image that adds a script that can send a SIGHUP signal to a container through the use of a label.

# The problem

The usual way of using `docker-gen` in conjunction with `docker-letsencrypt-nginx-proxy-companion` using the separate
container method, is as follows (as per the [docs](https://github.com/JrCs/docker-letsencrypt-nginx-proxy-companion#separate-containers-recommended-method)):

```
$ docker run -d \
    --name nginx-gen \
    --volumes-from nginx \
    -v /path/to/nginx.tmpl:/etc/docker-gen/templates/nginx.tmpl:ro \
    -v /var/run/docker.sock:/tmp/docker.sock:ro \
    jwilder/docker-gen \
    -notify-sighup nginx -watch -only-exposed -wait 5s:30s /etc/docker-gen/templates/nginx.tmpl /etc/nginx/conf.d/default.conf
```

However, within a Docker Cloud or Swarm Mode based environment we cannot use `-notify-sighup nginx` due to the fact that
the container names (on the actual nodes) do not match their service names.
The result is that the `nginx` container (Service) never get's reloaded to take advantage of the generated Nginx configuration.

# The solution

Add a label to the container you want to reload, with value `true`. Then, use the bundled `docker-label-sighup`
script, with the label name as an argument. For example:

```
services:
  nginx:
    image: nginx:alpine
    ports:
      - 80:80
      - 433:433
    volumes:
      - nginx:/etc/nginx/conf.d
      - nginx:/etc/nginx/certs
    labels:
      - com.example.nginx_proxy=true

  dockergen:
    image: helder/docker-gen:latest
    command: -notify "docker-label-sighup com.example.nginx_proxy" -watch -only-exposed -wait 10s:30s /etc/docker-gen/templates/nginx.tmpl /etc/nginx/conf.d/default.conf
    volumes:
      - nginx:/etc/nginx/conf.d
      - /var/run/docker.sock:/tmp/docker.sock:ro
      - ./nginx.tmpl:/etc/docker-gen/templates/nginx.tmpl

volumes:
  nginx:
```

Note the use of `-notify` instead of using `-notify-sighup` to redeploy the service using the bundled script.
