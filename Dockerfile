FROM docker.io/caddy:2.7.4-builder-alpine as builder
RUN xcaddy build \
    --with github.com/caddyserver/transform-encoder \
    --with github.com/caddyserver/forwardproxy@caddy2=github.com/klzgrad/forwardproxy@naive

FROM quay.io/llrealm/baseutil:prod
MAINTAINER leo.lou@gov.bc.ca

COPY --from=builder /usr/bin/caddy /usr/bin/    

LABEL name="Caddy" \
      vendor="Caddy" \
      version="v2.7.4" \
      release="CE" \
      url="https://caddyserver.com/" \
      io.openshift.tags="golang" \
      io.openshift.expose-services="8080:8443:8001:8444" \
      io.k8s.display-name="Caddy with transform encoder and forward-proxy" \
      io.k8s.description="Caddy with transform encoder and forward-proxy" \
      org.opencontainers.image.description DESCRIPTION="Caddy with transform encoder and forward-proxy"

ENV XDG_CONFIG_HOME /config
ENV XDG_DATA_HOME /data

VOLUME /config
VOLUME /data
EXPOSE 8080 8443 8001 8444
STOPSIGNAL SIGTERM
CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]
