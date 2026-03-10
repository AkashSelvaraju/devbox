#!/usr/bin/env bash
set -e

# Map UID/GID if provided
if [ -n "$HOST_UID" ] && [ -n "$HOST_GID" ]; then
    groupmod -o -g $HOST_GID dev || true
    usermod -o -u $HOST_UID dev || true
fi

# Fix docker socket permissions
if [ -S /var/run/docker.sock ]; then
    SOCK_GID=$(stat -c %g /var/run/docker.sock)
    if ! getent group $SOCK_GID >/dev/null; then
        groupadd -g $SOCK_GID dockersock
    fi
    usermod -aG $SOCK_GID dev
fi

# Fix home permissions
chown -R dev:dev /home/dev 2>/dev/null || true

exec /usr/sbin/sshd -D
