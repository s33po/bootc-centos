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
    sddm \
    sddm-breeze \
    sddm-kcm \

dnf -y install --nobest \
    NetworkManager-config-connectivity-redhat \
    ark \
    bluedevil \
    colord-kde \
    dolphin \
    ffmpegthumbs \
    filelight \
    flatpak-kcm \
    kde-gtk-config \
    kde-partitionmanager \
    kdegraphics-thumbnailers \
    kdialog \
    kdnssd \
    kio-admin \
    kjournald \
    konsole \
    kscreen \
    ksshaskpass \
    kwalletmanager5 \
    libappindicator-gtk3 \
    pam-kwallet \
    plasma-discover \
    plasma-discover-notifier \
    plasma-disks \
    plasma-nm \
    plasma-systemmonitor \
    plasma-vault \
    samba-usershares \
    spectacle \
    thermald \
    kate \
    okular \
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
