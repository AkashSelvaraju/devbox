# Devbox

A Docker-based Ubuntu 22.04 development environment for Kubernetes operator development with Go and common CLI tooling.

## Build the image

```bash
docker build -t devbox .
````

## SSH key setup for logging into the container
the keys mounted at /key/authorized_keys to the container will be installed as authorized keys for logging into the container via ssh as dev user

## Run the container on windows
copy your public ssh key to C:\devbox-ssh using the following command in cmd or powershell

```cmd
mkdir C:\devbox-ssh
cp %USERPROFILE%\.ssh\<your-dev-box-sshkey>.pub C:\devbox-ssh\authorized_keys
```

start the container using the following command in cmd or powershell
```cmd
docker run -d ^
  --name devbox ^
  --hostname devbox ^
  --restart unless-stopped ^
  -p 2222:22 ^
  -v "C:\devbox-ssh:/keys:ro" ^
  -v "%USERPROFILE%\workspace:/workspace" ^
  -v "%USERPROFILE%\Downloads:/downloads" ^
  -v devbox-home:/home/dev ^
  -v devbox-cache:/home/dev/.cache ^
  -v devbox-go-mod:/go/pkg/mod ^
  akashselvaraju/devbox:2.0.0
```

## Run the container on linux

copy your public ssh key to ~/.ssh/devbox-ssh using the following command in terminal

```bash
mkdir -p ~/devbox-sshkey
cp ~/.ssh/<your-dev-box-sshkey>.pub ~/.ssh/devbox-ssh/
```

run the container using the following command in terminal
```bash
docker run -d \
  --name devbox \
  --hostname devbox \
  --restart unless-stopped \
  -p 2222:22 \
  -v "C:\devbox-ssh:/keys:ro" \
  -v "%USERPROFILE%\workspace:/workspace" \
  -v "%USERPROFILE%\Downloads:/downloads" \
  -v devbox-home:/home/dev \
  -v devbox-cache:/home/dev/.cache \
  -v devbox-go-mod:/go/pkg/mod \
  akashselvaraju/devbox:2.0.0
```

## Enter the development shell

### using docker exec

```bash
docker exec -it -u dev devbox zsh
```

### using ssh

```bash
ssh -p 2222 dev@localhost
```
