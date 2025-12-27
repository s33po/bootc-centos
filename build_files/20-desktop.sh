#!/usr/bin/env bash

set -xeuo pipefail

# Install only specific langpacks for needed languages/locales (edit for your own needs)
dnf -y install glibc-langpack-{en,fi}

# Trimmed KDE with core apps and some weaker dependencies
dnf -y install --setopt=install_weak_deps=False \
    ark \
    breeze-gtk-gtk3 \
    default-fonts-core \
    dolphin \
    flatpak \
    flatpak-kcm \
    kate \
    kate-plugins \
    kde-gtk-config \
    kde-partitionmanager \
    kdegraphics-thumbnailers \
    kf6-baloo-file \
    kio-admin \
    kjournald \
    konsole \
    kscreen \
    ksshaskpass \
    pam-kwallet \
    pipewire \
    plymouth-system-theme \
    plasma-desktop \
    plasma-discover \
    plasma-discover-flatpak \
    plasma-disks \
    plasma-milou \
    plasma-nm \
    plasma-pa \
    qt6-qtimageformats \
    samba-client \
    sddm \
    sddm-breeze \
    spectacle \
    udev-hid-bpf-stable \
    upower \
    usbutils \
    zip
