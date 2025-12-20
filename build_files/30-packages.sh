#!/usr/bin/env bash

set -xeuo pipefail

# Install extra packages
dnf -y install \
    alsa-sof-firmware \
    borgbackup \
    btop \
    cifs-utils \
    container-tools \
    davfs2 \
    distrobox \
    fastfetch \
    fpaste \
    fuse \
    fzf \
    fwupd \
    git \
    ifuse \
    just \
    libxcrypt-compat \
    lm_sensors \
    make \
    nvtop \
    ntfs-3g \
    plymouth \
    plymouth-system-theme \
    plymouth-theme-spinner \
    powertop \
    rclone \
    restic \
    steam-devices \
    system-reinstall-bootc \
    systemd-container \
    tmux \
    uv \
    wl-clipboard \
    wireguard-tools \
    xhost \
    zsh
