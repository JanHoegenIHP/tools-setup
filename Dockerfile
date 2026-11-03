# _________________________________________________________
# Nix Stage

# FROM ubuntu:24.04 AS nix-builder
# ENV DEBIAN_FRONTEND=noninteractive

# RUN apt-get update && apt-get install -y --no-install-recommends curl xz-utils ca-certificates
# RUN curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install linux --no-confirm --init none --no-start-daemon \
#     --extra-conf "extra-substituters = https://nix-cache.fossi-foundation.org" \
#     --extra-conf "extra-trusted-public-keys = nix-cache.fossi-foundation.org:3+K59iFwXqKsL7BNu6Guy0v+uTlwsxYQxjspXzqLYQs=" \
#     --extra-conf "extra-experimental-features = nix-command flakes" \
#     --extra-conf "sandbox = false" \
#     --extra-conf "build-users-group ="

# _________________________________________________________
# UV Stage

FROM ghcr.io/astral-sh/uv:latest AS uv-source


# _________________________________________________________
# Base OS
# same as OSIC-IIC toolchain

FROM ubuntu:24.04
ENV DEBIAN_FRONTEND=noninteractive
RUN useradd --shell /bin/bash --create-home developer

# LABEL org.opencontainers.image.title="Open Source ASIC Development Environment"
# LABEL org.opencontainers.image.description="Containerized open-source ASIC design toolchain"
# LABEL org.opencontainers.image.licenses="Apache-2.0"
# LABEL org.opencontainers.image.authors="authoremail@example.com"
# LABEL "com.example.vendor"="Example LLC"
# LABEL version="1.0.0"
# LABEL description="This image is used to run hello world backend written in Express Framework"

# COPY --from=nix-builder /nix /nix
# RUN chown -R developer:developer /nix
# ENV PATH="${PATH}:/nix/var/nix/profiles/default/bin"

COPY --from=uv-source /uv /uvx /usr/local/bin/
# ENV UV_LINK_MODE=copy


# _________________________________________________________
# OS tools

RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    wget \
    curl \
    make \
    && rm -rf /var/lib/apt/lists/*

RUN curl --proto '=https' --tlsv1.2 -fsSL https://artifacts.nixos.org/nix-installer | sh -s -- install linux --init none --no-confirm \
    --extra-conf "extra-substituters = https://nix-cache.fossi-foundation.org" \
    --extra-conf "extra-trusted-public-keys = nix-cache.fossi-foundation.org:3+K59iFwXqKsL7BNu6Guy0v+uTlwsxYQxjspXzqLYQs=" \
    --extra-conf "extra-experimental-features = nix-command flakes" \
    --extra-conf "sandbox = false" 
ENV PATH="/nix/var/nix/profiles/default/bin:${PATH}"

# _________________________________________________________
# Development Tools

RUN apt-get update && apt-get install -y \
    python3 \
    python3-venv \
    python3-pip \
    python3-tk \
    && rm -rf /var/lib/apt/lists/*


# _________________________________________________________
# Digital Design

RUN git clone https://github.com/librelane/librelane /opt/librelane
RUN /nix/bin/nix-daemon & cd /opt/librelane && nix-shell --no-sandbox --run "echo 'Nix environment initialized successfully'"
RUN chown -R developer:developer /opt/librelane

RUN apt-get update && apt-get install -y \
    ghdl \
    gtkwave \
    klayout \
    && rm -rf /var/lib/apt/lists/*


# _________________________________________________________
# New User

WORKDIR /workspace
RUN chown developer:developer /workspace
USER developer
