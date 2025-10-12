#!/usr/bin/env bash

set -xeuo pipefail

# Remove subscription-manager and install dnf commands
dnf remove -y subscription-manager
dnf -y install 'dnf-command(config-manager)' 'dnf-command(versionlock)' time

# Set global dnf options
dnf config-manager --save \
    --setopt=max_parallel_downloads=10 \
    --setopt=exclude="\
        PackageKit,PackageKit-command-not-found,rootfiles,redhat-flatpak-repo,\
        firefox,loupe,gnome-characters,gnome-font-viewer,gnome-user-docs,\
        glibc-all-langpacks,cldr-emoji-annotation,\
        default-fonts-*,google-noto-*\
    "
    
# Enable CRB and install EPEL
dnf install -y 'dnf-command(config-manager)' epel-release
dnf config-manager --set-enabled crb
dnf upgrade -y epel-release