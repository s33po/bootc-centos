#!/usr/bin/env bash

set -xeuo pipefail

# Install only specific langpacks for needed languages/locales (edit for your own needs)
dnf -y install glibc-langpack-{en,fi}

# Smallish set of basic fonts
dnf -y install \
    default-fonts-core \
    google-noto-sans-fonts \
    liberation-fonts \
    fira-code-fonts

# "Workstation" without default fonts, browser and printing support (edit for your own needs)
dnf -y group install \
    "base-graphical" \
    "Common NetworkManager submodules" \
    "Core" \
    "GNOME" \
    "Guest Desktop Agents" \
    "Hardware Support" \
    "Multimedia" \
    "Standard" \
    "Workstation product core"

# Basic support for image thumbnailing, previews and wallpapers
dnf -y install \
    avif-pixbuf-loader \
    gdk-pixbuf2-modules-extra \
    jxl-pixbuf-loader \
    libjxl \
    webp-pixbuf-loader
