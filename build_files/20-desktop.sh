#!/usr/bin/env bash

set -xeuo pipefail

# Install only specific langpacks for needed languages/locales (edit for your own needs)
# This saves +200 MB compared to installing the full 'glibc-all-langpacks'
dnf -y install glibc-langpack-{en,fi}

# "Workstation" with KDE
dnf -y group install "KDE Plasma Workspaces" \

# Basic apps and fonts
dnf -y install \
    kcalc \
	okular \
	kate \
	filelight \
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
