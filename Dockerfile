FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# ------------------------------------------------
# Base packages
# ------------------------------------------------
RUN apt-get update && apt-get install -y \
    build-essential \
    gcc \
    make \
    git \
    curl \
    wget \
    ca-certificates \
    unzip \
    tar \
    jq \
    ripgrep \
    vim \
    tmux \
    less \
    file \
    iputils-ping \
    dnsutils \
    net-tools \
    software-properties-common \
    zsh \
    sudo \
    bat \
    fzf \
    && rm -rf /var/lib/apt/lists/*

# ------------------------------------------------
# Install latest Go
# ------------------------------------------------
RUN GO_VERSION=$(curl -s https://go.dev/VERSION?m=text | head -n1) && \
    wget https://go.dev/dl/${GO_VERSION}.linux-amd64.tar.gz && \
    rm -rf /usr/local/go && \
    tar -C /usr/local -xzf ${GO_VERSION}.linux-amd64.tar.gz && \
    rm ${GO_VERSION}.linux-amd64.tar.gz

ENV PATH="/usr/local/go/bin:${PATH}"
ENV GOPATH=/go
ENV PATH="${PATH}:/go/bin"

# ------------------------------------------------
# kubectl
# ------------------------------------------------
RUN curl -LO https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl && \
    install -m 0755 kubectl /usr/local/bin/kubectl && \
    rm kubectl

# ------------------------------------------------
# kubectx + kubens
# ------------------------------------------------
RUN git clone https://github.com/ahmetb/kubectx /opt/kubectx && \
    ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx && \
    ln -s /opt/kubectx/kubens /usr/local/bin/kubens

# ------------------------------------------------
# k9s
# ------------------------------------------------
RUN K9S_VERSION=$(curl -s https://api.github.com/repos/derailed/k9s/releases/latest | grep tag_name | cut -d '"' -f4) && \
    curl -L https://github.com/derailed/k9s/releases/download/${K9S_VERSION}/k9s_Linux_amd64.tar.gz \
    | tar -xz && \
    mv k9s /usr/local/bin/

# ------------------------------------------------
# operator-sdk
# ------------------------------------------------
RUN curl -LO https://github.com/operator-framework/operator-sdk/releases/latest/download/operator-sdk_linux_amd64 && \
    chmod +x operator-sdk_linux_amd64 && \
    mv operator-sdk_linux_amd64 /usr/local/bin/operator-sdk

# ------------------------------------------------
# helm
# ------------------------------------------------
RUN curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# ------------------------------------------------
# k3s CLI and k3d
# ------------------------------------------------
RUN K3S_VERSION=$(curl -s https://api.github.com/repos/k3s-io/k3s/releases/latest | grep tag_name | cut -d '"' -f4) && \
    curl -L https://github.com/k3s-io/k3s/releases/download/${K3S_VERSION}/k3s -o /usr/local/bin/k3s && \
    chmod +x /usr/local/bin/k3s

RUN curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

# ------------------------------------------------
# starship prompt
# ------------------------------------------------
RUN curl -sS https://starship.rs/install.sh | sh -s -- -y

# ------------------------------------------------
# Oh My Zsh
# ------------------------------------------------
RUN git clone https://github.com/ohmyzsh/ohmyzsh.git /root/.oh-my-zsh

# ------------------------------------------------
# Zsh Plugins
# ------------------------------------------------
RUN git clone https://github.com/zsh-users/zsh-autosuggestions \
    ${ZSH_CUSTOM:-/root/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

RUN git clone https://github.com/zsh-users/zsh-syntax-highlighting \
    ${ZSH_CUSTOM:-/root/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

RUN git clone https://github.com/MichaelAquilina/zsh-you-should-use \
    ${ZSH_CUSTOM:-/root/.oh-my-zsh/custom}/plugins/you-should-use

# ------------------------------------------------
# Config files
# ------------------------------------------------
COPY dotfiles/.zshrc /root/.zshrc
COPY dotfiles/starship.toml /root/.config/starship.toml
COPY dotfiles/.vimrc /root/.vimrc

# ------------------------------------------------
# Default shell
# ------------------------------------------------
RUN chsh -s /usr/bin/zsh root

WORKDIR /workspace

CMD ["zsh"]
