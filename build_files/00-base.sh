#!/usr/bin/env bash

set -xeuo pipefail

# Remove subscription-manager and install dnf commands
dnf remove -y subscription-manager
dnf -y install 'dnf-command(config-manager)' 'dnf-command(versionlock)' time

# Set global dnf options
dnf config-manager --save \
    --setopt=max_parallel_downloads=10 \
    --setopt=exclude=loupe,PackageKit,PackageKit-command-not-found,rootfiles,firefox,redhat-flatpak-repo \
    --setopt=keepcache=false \
    --setopt=fastestmirror=false \
    --setopt=deltarpm=false
    
# Enable CRB and install EPEL
dnf install -y 'dnf-command(config-manager)' epel-release
dnf config-manager --set-enabled crb
dnf upgrade -y epel-release