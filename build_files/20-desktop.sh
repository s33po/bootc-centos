#!/usr/bin/env bash

set -xeuo pipefail

# Install only specific langpacks for needed languages/locales (edit for your own needs)
dnf -y install glibc-langpack-{en,fi}

# Trimmed KDE with core apps
dnf -y install --setopt=install_weak_deps=False \
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
    plasma-discover-flatpak \
    plasma-disks \
    plasma-nm \
    plasma-pa \
    plasma-systemmonitor \
    spectacle \
    kate \
    kcalc \
    plymouth-system-theme \
    NetworkManager-wifi \
    samba-client \
    kio-extras \
    pipewire \
    media-player-info \
    exiv2 \
    glib-networking \
    low-memory-monitor \
    udev-hid-bpf-stable \
    upower \
    usbutils \
    ibus \
    signon-kwallet-extension \
    qt6-qtimageformats \
    lsb_release \
    breeze-gtk-gtk3 \
    dolphin-plugins \
    kate-plugins \
    kate-krunner-plugin \
    kaccounts-providers

## Optional:
#dnf -y install \
#    kde-inotify-survey \
#    plasma-milou \
#    xsettingsd \
#    pipewire-jack-audio-connection-kit \
#    google-noto-serif-fonts \
#    iio-sensor-proxy \
#    libproxy-bin \
#    usbmuxd
