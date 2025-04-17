FROM docker.io/caddy:2.9.1-builder-alpine as builder
RUN xcaddy build \
    --with github.com/caddyserver/transform-encoder \
    --with github.com/caddyserver/forwardproxy@caddy2=github.com/klzgrad/forwardproxy@naive

FROM quay.io/llrealm/baseutil:prod
MAINTAINER leo.lou@gov.bc.ca

USER 0

COPY --from=builder /usr/bin/caddy /usr/bin/
COPY entrypoint.sh /entrypoint.sh

LABEL name="Caddy" \
      vendor="Caddy" \
      version="v2.9.1" \
      release="CE" \
      url="https://caddyserver.com/" \
      io.openshift.tags="golang" \
      io.openshift.expose-services="8080:8443:8001:8444" \
      io.k8s.display-name="Caddy with transform encoder and forward-proxy" \
      io.k8s.description="Caddy with transform encoder and forward-proxy" \
      org.opencontainers.image.description="Caddy with transform encoder and forward-proxy"

RUN deluser app && adduser -S caddy \
  && chown -R caddy:0 /home/caddy && chmod -R 775 /home/caddy/ \
  && chown -R caddy:0 /usr/bin/caddy \
  && chmod 664 /etc/passwd && chmod 755 /entrypoint.sh

USER caddy
WORKDIR /home/caddy/
ENV XDG_CONFIG_HOME /config
ENV XDG_DATA_HOME /data

VOLUME /config
VOLUME /data
EXPOSE 8080 8443 8001 8444
STOPSIGNAL SIGTERM
ENTRYPOINT ["/entrypoint.sh"]
CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]