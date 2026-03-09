# Devbox

A Docker-based Ubuntu 22.04 development environment for Kubernetes operator development with Go and common CLI tooling.

## Build the image

```bash
docker build -t devbox .
````

## Run the container

```bash
docker run -d \
  --name devbox \
  --restart unless-stopped \
  -v C:\dev:/workspace \
  -v dev-home:/root \
  -v dev-cache:/root/.cache \
  -v go-mod:/go/pkg/mod \
  -w /workspace \
  devbox \
  sleep infinity
```

## Enter the development shell

```bash
docker exec -it devbox zsh
```
