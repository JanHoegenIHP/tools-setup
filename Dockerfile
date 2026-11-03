# _________________________________________________________
# UV Stage

FROM ghcr.io/astral-sh/uv:latest AS uv-source


# _________________________________________________________
# Base OS
# same as OSIC-IIC toolchain

FROM ubuntu:24.04
ENV DEBIAN_FRONTEND=noninteractive

# LABEL org.opencontainers.image.title="Open Source ASIC Development Environment"
# LABEL org.opencontainers.image.description="Containerized open-source ASIC design toolchain"
# LABEL org.opencontainers.image.licenses="Apache-2.0"
# LABEL org.opencontainers.image.authors="authoremail@example.com"
# LABEL "com.example.vendor"="Example LLC"
# LABEL version="1.0.0"
# LABEL description="This image is used to run hello world backend written in Express Framework"

COPY --from=uv-source /uv /uvx /usr/local/bin/


# _________________________________________________________
# OS tools

# Install basic utilities
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    wget \
    curl \
    make \
    && rm -rf /var/lib/apt/lists/*

# install nix package manager
RUN curl --proto '=https' --tlsv1.2 -fsSL https://artifacts.nixos.org/nix-installer | sh -s -- install linux --init none --no-confirm \
    --extra-conf "extra-substituters = https://nix-cache.fossi-foundation.org" \
    --extra-conf "extra-trusted-public-keys = nix-cache.fossi-foundation.org:3+K59iFwXqKsL7BNu6Guy0v+uTlwsxYQxjspXzqLYQs=" \
    --extra-conf "extra-experimental-features = nix-command flakes" 


# _________________________________________________________
# Development Tools

RUN apt-get update && apt-get install -y \
    python3 \
    python3-dev \
    python3-venv \
    python3-pip \
    python3-tk \
    && rm -rf /var/lib/apt/lists/*

# RUN curl -LsSf https://astral.sh/uv/install.sh | sh
# ENV UV_LINK_MODE=copy


# _________________________________________________________
# Digital Design

RUN git clone https://github.com/librelane/librelane /opt/librelane
    # cd /opt/librelane 
    # uv pip install --system -e .

RUN apt-get update && apt-get install -y \
    ghdl \
    gtkwave \
    klayout \
    libxcb-cursor0 \
    libxcb-icccm4 \
    libxcb-image0 \
    libxcb-keysyms1 \
    libxcb-randr0 \
    libxcb-render-util0 \
    libxcb-shape0 \
    libxcb-shm0 \
    libxcb-sync1 \
    libxcb-xinerama0 \
    libxcb-xfixes0 \
    libxcb-xkb1 \
    libxkbcommon0 \
    libxkbcommon-x11-0 \
    && rm -rf /var/lib/apt/lists/*


# _________________________________________________________
# New User

RUN useradd --shell /bin/bash --create-home developer
WORKDIR /workspace
RUN chown developer:developer /workspace
USER developer
