#!/usr/bin/env bash

set -xeuo pipefail

# Remove subscription-manager, install dnf-plugins, EPEL and enable CRB
dnf -y remove subscription-manager console-login-helper-messages
dnf -y install 'dnf-command(versionlock)' epel-release
dnf config-manager --set-enabled crb
dnf -y upgrade epel-release

# Set global dnf options
dnf config-manager --save \
    --setopt=max_parallel_downloads=10 \
    --setopt=exclude="\
        PackageKit,PackageKit-command-not-found,rootfiles,redhat-flatpak-repo,setroubleshoot,\
        firefox,loupe,gnome-characters,gnome-font-viewer,gnome-user-docs,\
        glibc-all-langpacks,cldr-emoji-annotation,ibus-typing-booster,gnome-shell-extension-background-logo,\
        centos-backgrounds,gnome-remote-desktop,libsane-hpaio,sane-backends-drivers-scanners,yelp-tools,NetworkManager-adsl
    "