# _________________________________________________________
# Nix Stage
# the nix store ships:
# - python3
# - gtkwave
# - verilator
# - iverlog
# - klayout
# - magic
# - netgen 
# - openorad
# - openroad-abc
# - opensta
# - ruby
# - tcl
# - yosys

FROM ubuntu:24.04 AS nix-builder

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    xz-utils \
    ca-certificates \
    git

RUN curl --proto '=https' --tlsv1.2 -fsSL https://artifacts.nixos.org/nix-installer | \
    sh -s -- install linux --init none --no-confirm \
    --extra-conf "extra-substituters = https://nix-cache.fossi-foundation.org" \
    --extra-conf "extra-trusted-public-keys = nix-cache.fossi-foundation.org:3+K59iFwXqKsL7BNu6Guy0v+uTlwsxYQxjspXzqLYQs=" \
    --extra-conf "extra-experimental-features = nix-command flakes" \
    --extra-conf "sandbox = false"

ENV PATH="/nix/var/nix/profiles/default/bin:${PATH}"

RUN git clone https://github.com/librelane/librelane /opt/librelane
WORKDIR /opt/librelane
RUN nix-build shell.nix --no-out-link > /tmp/shell-path

RUN nix print-dev-env --file shell.nix \
    > /etc/eda-environment.sh
RUN set -eux; \
    mkdir -p /opt/nix-runtime/nix/store; \
    shell_path="$(cat /tmp/shell-path)"; \
    nix-store -qR "$shell_path" > /tmp/closure; \
    while read -r path; do \
        cp -a "$path" /opt/nix-runtime/nix/store/; \
    done < /tmp/closure

# _________________________________________________________
# UV Stage

FROM ghcr.io/astral-sh/uv:latest AS uv-source


# _________________________________________________________
# Base OS
# same as OSIC-IIC toolchain

FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV QT_X11_NO_MITSHM=1

ENV LANG=C.UTF-8

LABEL org.opencontainers.image.created="2024-06-10T12:00:00Z"
LABEL org.opencontainers.image.authors="Jan Hoegen"
LABEL org.opencontainers.image.url="https://github.com/JanHoegenIHP/tools-setup"
LABEL org.opencontainers.image.version="0.0.1"
LABEL org.opencontainers.image.vendor="Hochschule Karlsruhe"
LABEL org.opencontainers.image.licenses="todo"
LABEL org.opencontainers.image.title="Open Source ASIC Development Environment"
LABEL org.opencontainers.image.description="Containerized open-source ASIC design toolchain"
LABEL org.opencontainers.image.base.name="registry.example.com/my-org/my-image:tag"


# _________________________________________________________
# Load Stages

COPY --from=nix-builder /opt/nix-runtime/nix/store /nix/store
COPY --from=nix-builder /etc/eda-environment.sh /etc/profile.d/eda-environment.sh
RUN chmod 644 /etc/profile.d/eda-environment.sh

COPY --from=uv-source /uv /uvx /usr/local/bin/
COPY ihp-requirements.txt /tmp/ihp-requirements.txt
ENV UV_LINK_MODE=copy
ENV UV_PROJECT_ENVIRONMENT=/home/developer/.venv


# _________________________________________________________
# OS tools

RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    wget \
    curl \
    make \
    sudo \
    && rm -rf /var/lib/apt/lists/*


# _________________________________________________________
# Digital Design

RUN apt-get update && apt-get install -y \
    ghdl \
    python3-pip \
    pipx \
    && rm -rf /var/lib/apt/lists/*

# Keep the IHP Python packages isolated from the Nix toolchain and example env.
RUN uv venv --python /usr/bin/python3 /opt/ihp-venv && \
    uv pip install --python /opt/ihp-venv/bin/python -r /tmp/ihp-requirements.txt && \
    rm /tmp/ihp-requirements.txt
ENV PATH="/opt/ihp-venv/bin:${PATH}"


# _________________________________________________________
# PDK

# ! The pdk dir lives on the host machine. Make sure to mount it into the container at /pdks when running the container.
ENV PDK_ROOT=/pdks
ENV PDK=ihp-sg13g2
ENV KLAYOUT_HOME=/home/developer/.klayout
ENV KLAYOUT_PATH=/home/developer/.klayout


# _________________________________________________________
# User Settings

RUN useradd --shell /bin/bash --create-home developer

RUN mkdir -p /workspace /pdks
RUN chown -R developer:developer /workspace /pdks

RUN printf '%s\n' \
    'source /etc/profile.d/eda-environment.sh' \
    'export PATH="/opt/ihp-venv/bin:$PATH"' \
    'if [ -d /usr/lib/wsl/lib ]; then export LD_LIBRARY_PATH="/usr/lib/wsl/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"; fi' \
    'export KLAYOUT_HOME="${KLAYOUT_HOME:-$HOME/.klayout}"' \
    'export KLAYOUT_PATH="${KLAYOUT_PATH:-$KLAYOUT_HOME:$PDK_ROOT/${PDK:-ihp-sg13g2}/libs.tech/klayout}"' \
    'unset IN_NIX_SHELL' \
    'export SHELL=/bin/bash' \
    "export PS1='\u@\h:\w\$ '" \
    >> /home/developer/.bashrc
RUN chown developer:developer /home/developer/.bashrc

RUN printf '%s\n' \
    'source "$HOME/.bashrc"' \
    > /home/developer/.bash_profile
RUN chown developer:developer /home/developer/.bash_profile

WORKDIR /workspace
USER developer
CMD ["/bin/bash", "--login"]