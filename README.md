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
  --hostname devbox \
  --restart unless-stopped \
  -p 2222:22 \
  -v C:\Users\dev\workspace:/workspace \
  -v dev-home:/home/dev \
  -v dev-cache:/home/dev/.cache \
  -v go-mod:/go/pkg/mod \
  -v C:\Users\dev\.ssh:/home/dev/.ssh \
  -v C:\Users\dev\.kube:/home/dev/.kube \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -w /workspace \
  devbox
```

## Enter the development shell

```bash
docker exec -it devbox zsh
```
