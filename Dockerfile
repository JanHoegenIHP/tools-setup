# _________________________________________________________
# Nix Stage

# FROM ubuntu:24.04 AS nix-builder
# ENV DEBIAN_FRONTEND=noninteractive

# RUN apt-get update && apt-get install -y --no-install-recommends curl xz-utils ca-certificates
# RUN curl --proto '=https' --tlsv1.2 -fsSL https://artifacts.nixos.org/nix-installer | sh -s -- install linux --init none --no-confirm \
#     --extra-conf "extra-substituters = https://nix-cache.fossi-foundation.org" \
#     --extra-conf "extra-trusted-public-keys = nix-cache.fossi-foundation.org:3+K59iFwXqKsL7BNu6Guy0v+uTlwsxYQxjspXzqLYQs=" \
#     --extra-conf "extra-experimental-features = nix-command flakes" \
#     --extra-conf "sandbox = false"

# _________________________________________________________
# UV Stage

FROM ghcr.io/astral-sh/uv:latest AS uv-source


# _________________________________________________________
# Base OS
# same as OSIC-IIC toolchain

FROM ubuntu:24.04
ENV DEBIAN_FRONTEND=noninteractive
ENV QT_X11_NO_MITSHM=1

# ENV LANG=C.UTF-8
# ENV LC_ALL=C.UTF-8
# ENV TZ=Europe/Berlin
# LABEL org.opencontainers.image.title="Open Source ASIC Development Environment"
# LABEL org.opencontainers.image.description="Containerized open-source ASIC design toolchain"
# LABEL org.opencontainers.image.licenses="Apache-2.0"
# LABEL org.opencontainers.image.authors="authoremail@example.com"
# LABEL "com.example.vendor"="Example LLC"
# LABEL version="1.0.0"
# LABEL description="This image is used to run hello world backend written in Express Framework"

# COPY --from=nix-builder --chown=developer:developer /nix /nix
# ENV PATH="/nix/var/nix/profiles/default/bin:${PATH}"


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
# Nix Package Manager

RUN curl --proto '=https' --tlsv1.2 -fsSL https://artifacts.nixos.org/nix-installer | sh -s -- install linux --init none --no-confirm \
    --extra-conf "extra-substituters = https://nix-cache.fossi-foundation.org" \
    --extra-conf "extra-trusted-public-keys = nix-cache.fossi-foundation.org:3+K59iFwXqKsL7BNu6Guy0v+uTlwsxYQxjspXzqLYQs=" \
    --extra-conf "extra-experimental-features = nix-command flakes" \
    --extra-conf "sandbox = false" 

ENV PATH="/nix/var/nix/profiles/default/bin:${PATH}"


# _________________________________________________________
# Development Tools

COPY --from=uv-source /uv /uvx /usr/local/bin/
# ENV UV_LINK_MODE=copy
ENV UV_PROJECT_ENVIRONMENT=/home/developer/.venv
# RUN uv sync


# _________________________________________________________
# Digital Design



WORKDIR /opt
RUN git clone https://github.com/librelane/librelane 
WORKDIR /opt/librelane
RUN git checkout main

RUN set -eux; \
    nix print-dev-env --extra-experimental-features nix-command --no-sandbox --file /opt/librelane/shell.nix \
        > /tmp/eda-environment.sh; \
    test -s /tmp/eda-environment.sh; \
    mv /tmp/eda-environment.sh /etc/profile.d/eda-environment.sh; \
    chmod 644 /etc/profile.d/eda-environment.sh

RUN apt-get update && apt-get install -y \
    ghdl \
    && rm -rf /var/lib/apt/lists/*


# _________________________________________________________
# New User

RUN useradd --shell /bin/bash --create-home developer

RUN chown -R developer:developer /nix

RUN mkdir -p /workspace
RUN chown -R developer:developer /workspace

RUN printf '%s\n' \
    'if [[ -f /etc/profile.d/eda-environment.sh ]]; then' \
    '    source /etc/profile.d/eda-environment.sh' \
    'fi' \
    '' \
    '# Restore normal Ubuntu shell identity' \
    'export SHELL=/bin/bash' \
    "export PS1='\u@\h:\w\$ '" \
    'unset IN_NIX_SHELL' \
    >> /home/developer/.bashrc
RUN chown developer:developer /home/developer/.bashrc

RUN printf '%s\n' \
    'source "$HOME/.bashrc"' \
    > /home/developer/.bash_profile
RUN chown developer:developer /home/developer/.bash_profile

WORKDIR /workspace

CMD ["/bin/bash", "--login"]


# _________________________________________________________
# PDK

ENV PDK_ROOT=/pdks
ENV PDK=ihp-sg13g2

RUN /bin/bash --login -c "ciel enable --pdk-family ihp-sg13g2 c4b8b4e5e7a05f375cca3815d51b3a37721fbf5c"
RUN chown -R developer:developer /pdks



USER developer