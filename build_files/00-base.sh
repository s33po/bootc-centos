#!/usr/bin/env bash

set -xeuo pipefail

# Remove subscription-manager, install EPEL and enable CRB
dnf -y remove subscription-manager
dnf config-manager --set-enabled crb
dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-10.noarch.rpm

# Set global dnf options
dnf config-manager --save \
    --setopt=max_parallel_downloads=10 \
    --setopt=exclude="\
        PackageKit,PackageKit-command-not-found,rootfiles,plasma-discover-kns,plasma-discover-packagekit,\
        plasma-workspace-wallpapers,redhat-flatpak-repo,setroubleshoot,firefox,glibc-all-langpacks,\
        ibus-typing-booster,cldr-emoji-annotation,plasma-welcome,xwaylandvideobridge,\
        nvidia-gpu-firmware,intel-gpu-firmware,iwlwifi-dvm-firmware
    "
