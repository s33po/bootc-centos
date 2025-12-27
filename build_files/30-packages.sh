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
    ripgrep \
    steam-devices \
