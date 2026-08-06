FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# ------------------------------------------------
# Base packages
# ------------------------------------------------

RUN apt-get update && apt-get install -y --no-install-recommends \
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
    less \
    file \
    iputils-ping \
    dnsutils \
    net-tools \
    software-properties-common \
    zsh \
    sudo \
    bat \
    openssh-server


# Create a non-root user
RUN useradd -m -s /usr/bin/zsh dev \
  && echo "dev ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/dev \
  && chmod 0440 /etc/sudoers.d/dev


# ------------------------------------------------
# SSH server setup
# ------------------------------------------------
RUN mkdir -p /etc/ssh/sshd_config.d /run/sshd \
  && printf '%s\n' \
    'PubkeyAuthentication yes' \
    'PasswordAuthentication no' \
    'PermitRootLogin no' \
    > /etc/ssh/sshd_config.d/99-custom.conf

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
RUN mkdir -p ${GOPATH}/pkg/mod ${GOPATH}/bin /home/dev/.cache

# ------------------------------------------------
# herdr
# ------------------------------------------------
RUN curl -fsSL https://herdr.dev/install.sh | sh

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
RUN curl -L https://github.com/derailed/k9s/releases/download/v0.51.0/k9s_Linux_amd64.tar.gz \
    | tar -xz && \
    mv k9s /usr/local/bin/

# ------------------------------------------------
# operator-sdk
# ------------------------------------------------
RUN curl -LO https://github.com/operator-framework/operator-sdk/releases/latest/download/operator-sdk_linux_amd64 && \
    chmod +x operator-sdk_linux_amd64 && \
    mv operator-sdk_linux_amd64 /usr/local/bin/operator-sdk

# ------------------------------------------------
# OpenShift CLI (oc)
# ------------------------------------------------
RUN curl -L "https://mirror.openshift.com/pub/openshift-v4/clients/ocp/stable/openshift-client-linux.tar.gz" \
    | tar -xz -C /tmp && \
    install -m 0755 /tmp/oc /usr/local/bin/oc && \
    install -m 0755 /tmp/kubectl /usr/local/bin/kubectl && \
    rm -f /tmp/oc /tmp/kubectl

# ------------------------------------------------
# helm
# ------------------------------------------------
RUN curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

RUN mkdir -p /home/dev/.oh-my-zsh \
 && chown -R dev:dev /home/dev

USER dev
WORKDIR /home/dev

# ------------------------------------------------
# starship prompt
# ------------------------------------------------
RUN curl -sS https://starship.rs/install.sh | sh -s -- -y

# ------------------------------------------------
# Oh My Zsh
# ------------------------------------------------
RUN git clone https://github.com/ohmyzsh/ohmyzsh.git /home/dev/.oh-my-zsh

# ------------------------------------------------
# Zsh Plugins
# ------------------------------------------------
RUN git clone https://github.com/zsh-users/zsh-autosuggestions \
    /home/dev/.oh-my-zsh/custom/plugins/zsh-autosuggestions

RUN git clone https://github.com/zsh-users/zsh-syntax-highlighting \
    /home/dev/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

RUN git clone https://github.com/MichaelAquilina/zsh-you-should-use \
    /home/dev/.oh-my-zsh/custom/plugins/you-should-use

# ------------------------------------------------
# Config files
# ------------------------------------------------
USER root

COPY dotfiles/.zshrc /home/dev/.zshrc
COPY dotfiles/starship.toml /home/dev/.config/starship.toml
COPY dotfiles/.vimrc /home/dev/.vimrc

RUN chown -R dev:dev /home/dev

WORKDIR /workspace

COPY start-sshd.sh /usr/local/bin/start-sshd.sh

RUN chmod +x /usr/local/bin/start-sshd.sh

EXPOSE 22
CMD ["/usr/local/bin/start-sshd.sh"]
