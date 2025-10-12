#!/usr/bin/env bash

set -xeuo pipefail

# Backported GNOME 48 from HyperScale SIG
dnf -y copr enable @centoshyperscale/c10s-gnome-48
dnf -y upgrade glib2

# Install only specific langpacks for needed languages/locales etc. (edit for your own needs)
# This makes final image smaller and saves some build time/bandwidth
dnf -y install glibc-langpack-{en,fi,ja}

# Install "Workstation" without default fonts, browser and printing support (edit for your own needs)
# Includes GNOME and a basic set of packages for a desktop system
dnf -y group install --setopt=install_weak_deps=False \
    "base-graphical" \
    "Common NetworkManager submodules" \
    "Core" \
    "GNOME" \
    "Guest Desktop Agents" \
    "Hardware Support" \
    "Multimedia" \
    "Standard" \
    "Workstation product core"  

# Install basic support for image thumbnailing, previews and wallpapers
dnf -y install --setopt=install_weak_deps=False \
    avif-pixbuf-loader \
    gdk-pixbuf2-modules-extra \
    jxl-pixbuf-loader \
    libjxl \
    webp-pixbuf-loader

# Disable HyperScale GNOME repo after desktop install
dnf -y copr disable @centoshyperscale/c10s-gnome-48