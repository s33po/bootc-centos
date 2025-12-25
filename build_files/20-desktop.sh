#!/usr/bin/env bash

set -xeuo pipefail

# Install only specific langpacks for needed languages/locales (edit for your own needs)
dnf -y install glibc-langpack-{en,fi}

# Trimmed KDE with core apps
dnf -y install --setopt=install_weak_deps=False \
    ark \
    bluedevil \
    breeze-gtk-gtk3 \
    default-fonts-core \
    dolphin \
    dolphin-plugins \
    exiv2 \
    filelight \
    flatpak-kcm \
    glib-networking \
    ibus \
    kate \
    kate-krunner-plugin \
    kate-plugins \
    kaccounts-providers \
    kcalc \
    kdialog \
    kde-gtk-config \
    kde-partitionmanager \
    kdegraphics-thumbnailers \
    kdeplasma-addons \
    kf6-baloo-file \
    kio-admin \
    kio-extras \
    kjournald \
    konsole \
    kscreen \
    ksshaskpass \
    lsb_release \
    low-memory-monitor \
    libproxy-bin \
    media-player-info \
    NetworkManager-wifi \
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
    plasma-systemmonitor \
    qt6-qtimageformats \
    samba-client \
    sddm \
    sddm-breeze \
    sddm-kcm \
    signon-kwallet-extension \
    spectacle \
    udev-hid-bpf-stable \
    upower \
    usbutils
