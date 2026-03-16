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
    cmake \
    pkg-config \
    gdb \
    git \
    curl \
    wget \
    ninja-build \
    ca-certificates \
    unzip \
    tar \
    jq \
    ripgrep \
    vim \
    htop \
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
    openssh-server

# ------------------------------------------------
# Python environment
# ------------------------------------------------
RUN apt-get install -y \
    python3 \
    python3-pip \
    python3-dev \
    python3-venv

RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

RUN pip3 install --upgrade pip

# ------------------------------------------------
# Core math / linear algebra
# ------------------------------------------------
RUN apt-get install -y \
    libeigen3-dev \
    libatlas-base-dev

# ------------------------------------------------
# OpenCV dependencies
# ------------------------------------------------
RUN apt-get install -y \
    libgtk-3-dev \
    libgl1-mesa-dev \
    libglib2.0-dev \
    libjpeg-dev \
    libpng-dev \
    libtiff-dev \
    libavcodec-dev \
    libavformat-dev \
    libswscale-dev \
    libv4l-dev \
    libxvidcore-dev \
    libx264-dev \
    libtbb-dev \
    libdc1394-dev

# ------------------------------------------------
# Point cloud processing
# ------------------------------------------------
RUN apt-get install -y \
    libpcl-dev

# ------------------------------------------------
# Visualization tools
# ------------------------------------------------
RUN apt-get install -y \
    vtk9 \
    libvtk9-dev \
    meshlab \
    ffmpeg

# ------------------------------------------------
# Install latest OpenCV
# ------------------------------------------------
WORKDIR /opt

RUN git clone https://github.com/opencv/opencv.git && \
    cd opencv && \
    git checkout 4.x

RUN mkdir /opt/opencv/build
WORKDIR /opt/opencv/build

RUN cmake .. \
    -D CMAKE_BUILD_TYPE=Release \
    -D CMAKE_INSTALL_PREFIX=/usr/local \
    -D BUILD_LIST=core,imgproc,highgui,videoio,dnn

RUN make -j$(nproc)
RUN make install
RUN ldconfig

# ------------------------------------------------
# Install ONNX Runtime
# ------------------------------------------------
WORKDIR /opt

RUN wget https://github.com/microsoft/onnxruntime/releases/download/v1.17.0/onnxruntime-linux-x64-1.17.0.tgz

RUN tar -xzf onnxruntime-linux-x64-1.17.0.tgz

RUN mv onnxruntime-linux-x64-1.17.0 /opt/onnxruntime

ENV ONNXRUNTIME_ROOT=/opt/onnxruntime

# ------------------------------------------------
# Python ML and visualization tools
# ------------------------------------------------
RUN pip install \
    numpy \
    scipy \
    matplotlib \
    pandas \
    seaborn \
    tqdm \
    jupyterlab \
    ipywidgets \
    plotly \
    open3d \
    onnx \
    onnxruntime

RUN pip install torch torchvision --index-url https://download.pytorch.org/whl/cpu

RUN pip install ultralytics

# ------------------------------------------------
# Dataset tools
# ------------------------------------------------
RUN pip install \
    nuscenes-devkit \
    pyquaternion

# ------------------------------------------------
# SSH server setup
# ------------------------------------------------
RUN mkdir /var/run/sshd

# create dev user
RUN useradd -m -s /usr/bin/zsh dev && \
    echo "dev:dev" | chpasswd && \
    usermod -aG sudo dev

# allow password login
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config


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
COPY dotfiles/.zshrc /home/dev/.zshrc
COPY dotfiles/.vimrc /home/dev/.vimrc

RUN chown -R dev:dev /home/dev

WORKDIR /workspace

EXPOSE 22

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

CMD ["/entrypoint.sh"]
