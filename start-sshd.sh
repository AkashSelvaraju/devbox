#!/usr/bin/env bash
set -euo pipefail

mkdir -p /run/sshd /home/dev/.ssh

# ------------------------------------------------
# Install authorized_keys if mounted from host
# ------------------------------------------------
if [ -f /keys/authorized_keys ]; then
  install -o dev -g dev -m 700 -d /home/dev/.ssh
  install -o dev -g dev -m 600 /keys/authorized_keys /home/dev/.ssh/authorized_keys
fi

# ------------------------------------------------
# Configure access to mounted Podman socket
# ------------------------------------------------
PODMAN_SOCK="/var/run/podman/podman.sock"

if [ -S "$PODMAN_SOCK" ]; then
  echo "[startup] Detected mounted Podman socket: $PODMAN_SOCK"

  SOCK_GID=$(stat -c '%g' "$PODMAN_SOCK")

  # Create a matching group if it doesn't exist
  if ! getent group "$SOCK_GID" >/dev/null 2>&1; then
    groupadd -g "$SOCK_GID" podman-host
  fi

  SOCK_GROUP=$(getent group "$SOCK_GID" | cut -d: -f1)

  # Add dev user to the socket group
  usermod -aG "$SOCK_GROUP" dev

  # Ensure the socket is group-accessible
  chmod 660 "$PODMAN_SOCK" || true

  echo "[startup] Added dev to group: $SOCK_GROUP (gid=$SOCK_GID)"

  # Make Podman/Docker use the mounted socket by default
  cat > /etc/profile.d/podman-socket.sh <<'EOF'
export CONTAINER_HOST=unix:///var/run/podman/podman.sock
export DOCKER_HOST=unix:///var/run/podman/podman.sock
EOF

  chmod 644 /etc/profile.d/podman-socket.sh
fi

# ------------------------------------------------
# Start SSH daemon
# ------------------------------------------------
ssh-keygen -A
exec /usr/sbin/sshd -D -e
