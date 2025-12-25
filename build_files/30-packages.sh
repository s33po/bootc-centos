#!/usr/bin/env bash

set -xeuo pipefail

# Install extra packages
dnf -y install \
    btop \
    fastfetch \
    fira-code-fonts \
    fzf \
    just \
    nvtop \
    steam-devices \
    tmux \
    vim \
    wireguard-tools \
    zsh
