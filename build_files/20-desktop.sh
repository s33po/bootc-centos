#!/usr/bin/env bash

set -xeuo pipefail

# Install only specific langpacks for needed languages/locales (edit for your own needs)
dnf -y install glibc-langpack-{en,fi}

# "Workstation" without DE and printing support
dnf -y group install \
    "base-graphical" \
    "Core" \
    "Fonts" \
    "Guest Desktop Agents" \
    "Hardware Support" \
    "Input Methods" \
    "Multimedia" \
    "Common NetworkManager submodules" \
    "Standard"

# Trimmed KDE with core apps
dnf -y install \
    plasma-desktop \
    sddm \
    sddm-breeze \
    sddm-kcm \
    ark \
    bluedevil \
    dolphin \
    flatpak-kcm \
    filelight \
    kde-gtk-config \
    kde-partitionmanager \
    kdegraphics-thumbnailers \
    kio-admin \
    kjournald \
    konsole \
    kscreen \
    ksshaskpass \
    pam-kwallet \
    plasma-discover \
    plasma-disks \
    plasma-nm \
    plasma-systemmonitor \
    spectacle \
    kate \
    kcalc \
    plymouth-system-theme

# Basic support for image thumbnailing
dnf -y install --setopt=install_weak_deps=False \
    avif-pixbuf-loader \
    gdk-pixbuf2-modules-extra \
    webp-pixbuf-loader
