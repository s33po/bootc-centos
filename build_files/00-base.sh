#!/usr/bin/env bash

set -xeuo pipefail

# Set /opt and /usr/local mutable
mkdir -p /var/{opt,usrlocal}
rm -rf /opt /usr/local
ln -sf /var/opt /opt
ln -sf /var/usrlocal /usr/local

# Remove subscription-manager, install dnf-plugins, EPEL and enable CRB
dnf -y remove subscription-manager console-login-helper-messages
dnf -y install 'dnf-command(versionlock)' epel-release
dnf config-manager --set-enabled crb
dnf -y upgrade epel-release

# Set global dnf options
dnf config-manager --save \
    --setopt=max_parallel_downloads=10 \
    --setopt=exclude="\
        PackageKit,PackageKit-command-not-found,rootfiles,plasma-discover-kns,\
        plasma-workspace-wallpapers,redhat-flatpak-repo,setroubleshoot,firefox,glibc-all-langpacks
    "
