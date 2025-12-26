#!/usr/bin/env bash

set -xeuo pipefail

# Install only specific langpacks for needed languages/locales (edit for your own needs)
dnf -y install glibc-langpack-{en,fi}

# "Workstation" without DE, fonts, printing support and guest agents
dnf -y group install \
    "base-graphical" \
    "Core" \
    "Multimedia" \
    "Common NetworkManager submodules" \
    "Standard"

# Trimmed KDE with core apps
dnf -y install \
    ark \
    bluedevil \
    breeze-gtk-gtk3 \
    default-fonts-core \
    dolphin \
    dolphin-plugins \
    filelight \
    flatpak-kcm \
    kate \
    kate-krunner-plugin \
    kate-plugins \
    kcalc \
    kdialog \
    kdnssd \
    kde-gtk-config \
    kde-partitionmanager \
    kdegraphics-thumbnailers \
    kf6-baloo-file \
    kio-admin \
    kio-extras \
    kjournald \
    konsole \
    kscreen \
    ksshaskpass \
    liberation-fonts \
    media-player-info \
    NetworkManager-wifi \
    pam-kwallet \
    pipewire \
    pipewire-alsa \
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
    redhat-display-vf-fonts \
    samba-client \
    sddm \
    sddm-breeze \
    sddm-kcm \
    spectacle \
    udev-hid-bpf-stable \
    upower \
    usbutils \
    zip
