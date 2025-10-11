#!/usr/bin/env bash

set -xeuo pipefail

echo "::group::🔧 BASE SETUP"

dnf remove -y subscription-manager
dnf -y install 'dnf-command(config-manager)' 'dnf-command(versionlock)'

# Set global dnf options
dnf config-manager --save \
    --setopt=max_parallel_downloads=10 \
    --setopt=exclude=loupe,PackageKit,PackageKit-command-not-found,rootfiles,firefox,redhat-flatpak-repo

# Enable CRB and install EPEL
dnf install -y 'dnf-command(config-manager)' epel-release
dnf config-manager --set-enabled crb
dnf upgrade -y epel-release

# Install gcc for brew (pulls kernel-headers)
dnf -y --setopt=install_weak_deps=False install gcc

echo "::endgroup::"

# Swap kernel (Hyperscale SIG)
#bash "$(dirname "$0")/kernel_hsk.sh"

# Swap kernel (Kmods SIG)
#bash "$(dirname "$0")/kernel_kmods.sh"

# Install desktop
bash "$(dirname "$0")/desktop.sh"

# Non-free multimedia codecs (mostly needed only for thumbnailing media files, as flatpaks have their own codecs)
#bash "$(dirname "$0")/multimedia.sh"

# Install packages
bash "$(dirname "$0")/packages.sh"

# Configure flatpaks
bash "$(dirname "$0")/flatpak.sh"

# Configure preferences
bash "$(dirname "$0")/preferences.sh"

# Enable/disable services
bash "$(dirname "$0")/services.sh"

# Configure plymouth and generate initramfs
bash "$(dirname "$0")/initramfs.sh"

echo "::group::🧹 CLEANUP"

# Final cleanup
dnf clean all
find /var -mindepth 1 -maxdepth 1 ! -path '/var/cache' -delete 2>/dev/null || true
find /var/cache -mindepth 1 ! -path '/var/cache/dnf*' -delete 2>/dev/null || true
mkdir -p /var /boot

# Make /usr/local writeable
ln -s /var/usrlocal /usr/local

echo "::endgroup::"