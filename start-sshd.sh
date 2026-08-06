#!/usr/bin/env bash
set -e

mkdir -p /run/sshd /home/dev/.ssh

# If you mount a folder from Windows at /keys,
# this copies your public key into the right place.
if [ -f /keys/authorized_keys ]; then
  install -o dev -g dev -m 700 -d /home/dev/.ssh
  install -o dev -g dev -m 600 /keys/authorized_keys /home/dev/.ssh/authorized_keys
fi

ssh-keygen -A
exec /usr/sbin/sshd -D -e
