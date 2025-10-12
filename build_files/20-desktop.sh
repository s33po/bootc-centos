#!/usr/bin/env bash

set -xeuo pipefail

# Backported GNOME 48 from HyperScale SIG
dnf -y copr enable @centoshyperscale/c10s-gnome-48
dnf -y install glib2

# Install "Workstation"
# Includes GNOME and a basic set of packages for a desktop system
dnf -y group install "Workstation"

# Install basic support for image thumbnailing, previews and wallpapers
dnf -y install --skip-broken --setopt=install_weak_deps=False \
    avif-pixbuf-loader \
    gdk-pixbuf2-modules-extra \
    jxl-pixbuf-loader \
    libjxl \
    webp-pixbuf-loader

# Remove fluff
dnf -y remove console-login-helper-messages setroubleshoot

# Disable HyperScale GNOME repo after desktop install
dnf -y copr disable @centoshyperscale/c10s-gnome-48