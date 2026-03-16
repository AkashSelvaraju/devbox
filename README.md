# Devbox

A Docker-based Ubuntu 22.04 development environment for Kubernetes operator development with Go and common CLI tooling.

## Build the image

```bash
docker build -t devbox_cv:<version> .
```

## Running the Devbox Container

Start the development container with:

```bash
docker run -d \
  --name devbox \
  --hostname devbox \
  --restart unless-stopped \
  -p 2222:22 \
  -e HOST_UID=$(id -u) \
  -e HOST_GID=$(id -g) \
  -v $HOME/workspace:/workspace \
  -v dev-home:/home/dev \
  -v dev-cache:/home/dev/.cache \
  -v /var/run/docker.sock:/var/run/docker.sock \
  --device=/dev/video0 \
  --group-add video \
  --shm-size=1g \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -w /workspace \
  akashselvaraju/devbox_cv:latest
```

### Container Configuration

#### Container Lifecycle

| Option                     | Description                                                  |
| -------------------------- | ------------------------------------------------------------ |
| `-d`                       | Run the container in detached (background) mode.             |
| `--name devbox`            | Assign the container the name **devbox**.                    |
| `--hostname devbox`        | Set the container’s internal hostname.                       |
| `--restart unless-stopped` | Automatically restart the container unless manually stopped. |

### Networking

| Option       | Description                                                            |
| ------------ | ---------------------------------------------------------------------- |
| `-p 2222:22` | Map host port **2222** to container **SSH port 22** for remote access. |

### User Identity

| Option                 | Description                                         |
| ---------------------- | --------------------------------------------------- |
| `-e HOST_UID=$(id -u)` | Pass the host user's UID to match file permissions. |
| `-e HOST_GID=$(id -g)` | Pass the host user's GID to match file permissions. |

### Volumes & Persistent Storage

| Option                                         | Description                                                                      |
| ---------------------------------------------- | -------------------------------------------------------------------------------- |
| `-v $HOME/workspace:/workspace`                | Mount host workspace directory inside the container.                             |
| `-v dev-home:/home/dev`                        | Persist the container user's home directory using a Docker volume.               |
| `-v dev-cache:/home/dev/.cache`                | Persist cache files to speed up builds and package installs.                     |
| `-v /var/run/docker.sock:/var/run/docker.sock` | Allow the container to access the host's Docker daemon (Docker-in-Docker style). |

### Hardware Access

| Option                 | Description                                                       |
| ---------------------- | ----------------------------------------------------------------- |
| `--device=/dev/video0` | Provide access to the host webcam device.                         |
| `--group-add video`    | Add container user to the **video** group for camera permissions. |

### GUI / Display Support

| Option                             | Description                                                         |
| ---------------------------------- | ------------------------------------------------------------------- |
| `-e DISPLAY=$DISPLAY`              | Forward the host X11 display environment variable.                  |
| `-v /tmp/.X11-unix:/tmp/.X11-unix` | Mount the X11 socket to enable GUI applications from the container. |

### Performance

| Option          | Description                                                                 |
| --------------- | --------------------------------------------------------------------------- |
| `--shm-size=1g` | Increase shared memory to **1GB** (important for OpenCV, ML, and browsers). |

### Working Directory

| Option          | Description                                            |
| --------------- | ------------------------------------------------------ |
| `-w /workspace` | Set the container’s working directory to `/workspace`. |

### Image

| Image                             | Description                                                 |
| --------------------------------- | ----------------------------------------------------------- |
| `akashselvaraju/devbox_cv:latest` | Development environment image with computer vision tooling. |

## Enter the development shell

```bash
docker exec -it -u dev devbox zsh
```
