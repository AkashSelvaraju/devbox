# Devbox

A Docker-based Ubuntu 22.04 development environment for Kubernetes operator development with Go and common CLI tooling.

## Build the image

```bash
docker build -t devbox .
````

## Run the container on windows

```cmd
docker run -d ^
  --name devbox ^
  --hostname devbox ^
  --restart unless-stopped ^
  -p 2222:22 ^
  -v C:\Users\<windows user name>\Work:/workspace ^
  -v dev-home:/home/dev ^
  -v dev-cache:/home/dev/.cache ^
  -v go-mod:/go/pkg/mod ^
  -v C:\Users\<windows user name>\.ssh:/home/dev/.ssh ^
  -v C:\Users\<windows user name>\.kube:/home/dev/.kube ^
  -v /var/run/docker.sock:/var/run/docker.sock ^
  -w /workspace ^
  akashselvaraju/devbox:latest
```

## Run the container on linux
```bash
docker run -d \
  --name devbox \
  --hostname devbox \
  --restart unless-stopped \
  -p 2222:22 \
  -e HOST_UID=$(id -u) \
  -e HOST_GID=$(id -g) \
  -v $HOME/Work:/workspace \
  -v dev-home:/home/dev \
  -v dev-cache:/home/dev/.cache \
  -v go-mod:/go/pkg/mod \
  -v $HOME/.ssh:/home/dev/.ssh \
  -v $HOME/.kube:/home/dev/.kube \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -w /workspace \
  akashselvaraju/devbox:1.1.0
```

## Enter the development shell

```bash
docker exec -it -u dev devbox zsh
```
