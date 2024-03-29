#!/bin/sh

## fix OpenShift random UID display correct username
if [[ $(id -u) -ge 10000 ]]; then
    GID=$(id -g)
    sed -e "s/^caddy:x:[^:]*:[^:]*:/caddy:x:$(id -u):$GID:/" /etc/passwd > /tmp/passwd
    cat /tmp/passwd > /etc/passwd
    rm /tmp/passwd
fi

## startup process
if [ "${1:0:1}" = '-' ]; then
    set -- caddy "$@"
fi

exec "$@"