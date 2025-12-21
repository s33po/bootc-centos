#!/usr/bin/env bash

set -xeuo pipefail

# Install only specific langpacks for needed languages/locales (edit for your own needs)
dnf -y install glibc-langpack-{en,fi}

# "Workstation" without DE, printing support and fonts
dnf -y group install --setopt=install_weak_deps=False \
    "base-graphical" \
    "Core" \
    "Guest Desktop Agents" \
    "Hardware Support" \
    "Input Methods" \
    "Multimedia" \
    "Common NetworkManager submodules" \
    "Standard"

# Trimmed KDE
dnf -y install --setopt=install_weak_deps=False \
    plasma-desktop \
    sddm \
    sddm-breeze \
    sddm-kcm \
    ark \
    bluedevil \
    dolphin \
    ffmpegthumbs \
    flatpak-kcm \
    kde-gtk-config \
    kde-partitionmanager \
    kdegraphics-thumbnailers \
    kio-admin \
    kjournald \
    konsole \
    kscreen \
    ksshaskpass \
    libappindicator-gtk3 \
    pam-kwallet \
    plasma-discover \
    plasma-discover-notifier \
    plasma-disks \
    plasma-nm \
    plasma-systemmonitor \
    samba-usershares \
    spectacle \
    thermald \
    kate \
    kcalc \
    plymouth-system-theme \
    clinfo

# Basic fonts
dnf -y install --setopt=install_weak_deps=False \
    liberation-fonts \
    dejavu-sans-fonts \
    fira-code-fonts \
    redhat-display-vf-fonts

# Basic support for image thumbnailing, previews and wallpapers
dnf -y install --setopt=install_weak_deps=False \
    avif-pixbuf-loader \
    gdk-pixbuf2-modules-extra \
    webp-pixbuf-loader
