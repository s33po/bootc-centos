#!/usr/bin/env bash

set -xeuo pipefail

# Install only specific langpacks for needed languages/locales (edit for your own needs)
# This saves +200 MB compared to installing the full 'glibc-all-langpacks'
dnf -y install glibc-langpack-{en,fi}

# "Workstation" without DE, printing support and fonts
dnf -y group install --nobest \
    "base-graphical" \
    "Core" \
    "Guest Desktop Agents" \
    "Hardware Support" \
    "Input Methods" \
    "Multimedia" \
    "Common NetworkManager submodules" \
    "Standard"

# Trimmed KDE
dnf -y install --nobest \
    plasma-desktop \
    plasma-workspace \
    plasma-workspace-wayland \
    sddm \
    sddm-breeze \
    sddm-kcm \
    sddm-wayland-plasma \
    alsa-sof-firmware \
    NetworkManager \
    NetworkManager-config-connectivity-redhat \
    ark \
    bluedevil \
    breeze-icon-theme \
    colord-kde \
    dolphin \
    ffmpegthumbs \
    filelight \
    flatpak-kcm \
    kde-gtk-config \
    kde-partitionmanager \
    kde-settings-pulseaudio \
    kdegraphics-thumbnailers \
    kdeplasma-addons \
    kdialog \
    kdnssd \
    kio-admin \
    kjournald \
    kmenuedit \
    konsole \
    kscreen \
    kscreenlocker \
    ksshaskpass \
    kwin \
    kwalletmanager5 \
    libappindicator-gtk3 \
    pam-kwallet \
    plasma-breeze \
    plasma-discover \
    plasma-discover-notifier \
    plasma-disks \
    plasma-nm \
    plasma-nm-openvpn \
    plasma-pa \
    plasma-systemmonitor \
    plasma-vault \
    polkit-kde \
    samba-usershares \
    spectacle \
    thermald \
    udisks2 \
    toolbox \
    xwaylandvideobridge \
    kate \
    okular \
    kcalc \
    xdg-desktop-portal-kde \
    plymouth-system-theme \
    vlc-plugin-streamer \
    clinfo

# Basic fonts
dnf -y install --setopt=install_weak_deps=False \
    google-noto-sans-fonts \
    liberation-fonts \
    dejavu-sans-fonts \
    fira-code-fonts \
    redhat-display-vf-fonts

# Basic support for image thumbnailing, previews and wallpapers
dnf -y install --setopt=install_weak_deps=False \
    avif-pixbuf-loader \
    gdk-pixbuf2-modules-extra \
    jxl-pixbuf-loader \
    libjxl \
    webp-pixbuf-loader
