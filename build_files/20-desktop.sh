#!/usr/bin/env bash

set -xeuo pipefail

# Install only specific langpacks for needed languages/locales (edit for your own needs)
dnf -y install glibc-langpack-{en,fi}

# Trimmed KDE with core apps
dnf -y install \
    plasma-desktop \
    sddm \
    sddm-breeze \
    sddm-kcm \
    ark \
    bluedevil \
    dolphin \
    default-fonts-core \
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
    plymouth-system-theme \
    NetworkManager-wifi

# Extras for image thumbnailing
dnf -y install --setopt=install_weak_deps=False \
    avif-pixbuf-loader \
    gdk-pixbuf2-modules-extra \
    webp-pixbuf-loader
