#!/usr/bin/env bash

set -xeuo pipefail

# Install extra packages
dnf -y install \
    btop \
    cifs-utils \
    container-tools \
    distrobox \
    fastfetch \
    fira-code-fonts \
    fuse \
    fzf \
    git \
    just \
    nvtop \
    steam-devices \
    system-reinstall-bootc \
    systemd-container \
    tmux \
    wireguard-tools \
    zsh
