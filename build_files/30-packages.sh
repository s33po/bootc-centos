#!/usr/bin/env bash

set -xeuo pipefail

# Install extra packages
dnf -y install \
    btop \
    cifs-utils \
    container-tools \
    distrobox \
    fastfetch \
    fuse \
    fzf \
    git \
    just \
    lm_sensors \
    nvtop \
    steam-devices \
    system-reinstall-bootc \
    systemd-container \
    tmux \
    wl-clipboard \
    wireguard-tools \
    zsh
