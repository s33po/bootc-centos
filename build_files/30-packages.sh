#!/usr/bin/env bash

set -xeuo pipefail

# Install extra packages
dnf -y install \
    container-tools \
    systemd-container \
    system-reinstall-bootc \
    btop \
    nvtop \
    distrobox \
    fuse \
    fastfetch \
    ntfs-3g \
    just \
    steam-devices \
    zsh \
    fzf \
    tmux \
    fpaste
