#!/usr/bin/env bash

set -xeuo pipefail

# Backported GNOME 48 from HyperScale SIG
dnf -y copr enable @centoshyperscale/c10s-gnome-48
dnf -y upgrade glib2

# Install only specific langpacks for needed languages/locales (edit for your own needs)
# This saves +200 MB compared to installing the full 'glibc-all-langpacks'
dnf -y install glibc-langpack-{en,fi}

# Install smallish set of basic fonts for system UI, terminal, basic document and web compatibility
# This saves +100 MB compared to installing the full "Fonts" group (you can install more fonts locally)
dnf -y install --setopt=install_weak_deps=False \
    google-noto-sans-fonts \
    liberation-fonts \
    dejavu-sans-fonts \
    fira-code-fonts \
    jetbrains-mono-fonts \
    redhat-display-vf-fonts

# Install "Workstation" without default fonts, browser and printing support (edit for your own needs)
# Includes GNOME and a basic set of packages for a desktop system
# Excluding "Printing client" (if you dont need it) saves about 100 MB
dnf -y group install --nobest --setopt=install_weak_deps=False \
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
