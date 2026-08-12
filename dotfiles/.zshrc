export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="gnzh"

plugins=(
  git
  kubectl
  k9s
  you-should-use
  zsh-autosuggestions
  zsh-syntax-highlighting
)

export GOPATH=$HOME/go
export PATH="${GOPATH}/bin:/usr/local/go/bin:/go/bin:${PATH}"

export PATH="$HOME/.local/bin:$PATH"

export PATH="/workspace/tools:${PATH}"
export PATH="/workspace/bin:${PATH}"

export CONTAIER_HOST="unix:///var/run/podman/podman.sock"
export DOCKER_HOST="unix:///var/run/podman/podman.sock"

source $ZSH/oh-my-zsh.sh

eval "$(starship init zsh)"
