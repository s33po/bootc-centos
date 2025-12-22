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
    nfs-utils \
    nvtop \
    steam-devices \
    system-reinstall-bootc \
    systemd-container \
    tmux \
    wireguard-tools \
    zsh
