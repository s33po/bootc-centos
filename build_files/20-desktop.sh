#!/usr/bin/env bash

set -xeuo pipefail

# Install only specific langpacks for needed languages/locales (edit for your own needs)
# This saves +200 MB compared to installing the full 'glibc-all-langpacks'
dnf -y install glibc-langpack-{en,fi}

# "Workstation" with KDE
dnf -y group install --nobest "KDE Plasma Workspaces" \

# Base
dnf -y install \
    plymouth \
    plymouth-system-theme \
    plymouth-theme-spinner \
    git \
    make \

# Some KDE apps and fonts
dnf -y install \
    kcalc \
    okular \
    kate \
    kunifiedpush \
    filelight \
    google-noto-emoji-fonts \
    google-noto-sans-fonts \
    fira-code-fonts \
    jetbrains-mono-fonts

# Basic support for image thumbnailing, previews and wallpapers
dnf -y install --setopt=install_weak_deps=False \
    avif-pixbuf-loader \
    gdk-pixbuf2-modules-extra \
    jxl-pixbuf-loader \
    libjxl \
    webp-pixbuf-loader
