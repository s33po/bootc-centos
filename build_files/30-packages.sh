#!/usr/bin/env bash

set -xeuo pipefail

# Install extra packages
dnf -y install \
    alsa-sof-firmware \
    btop \
    cifs-utils \
    container-tools \
    distrobox \
    fastfetch \
    fpaste \
    fuse \
    fzf \
    fwupd \
    git \
    ifuse \
    just \
    lm_sensors \
    make \
    nvtop \
    ntfs-3g \
    plymouth \
    plymouth-system-theme \
    plymouth-theme-spinner \
    powertop \
    steam-devices \
    system-reinstall-bootc \
    systemd-container \
    tmux \
    uv \
    wl-clipboard \
    wireguard-tools \
    xhost \
    zsh
