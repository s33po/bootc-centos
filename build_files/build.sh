#!/usr/bin/env bash

set -xeuo pipefail

dnf remove -y subscription-manager
dnf -y install 'dnf-command(config-manager)' 'dnf-command(versionlock)'

# Configure bootc updates
sed -i 's|^ExecStart=.*|ExecStart=/usr/bin/bootc update --quiet|' /usr/lib/systemd/system/bootc-fetch-apply-updates.service
sed -i 's|^OnUnitInactiveSec=.*|OnUnitInactiveSec=7d\nPersistent=true|' /usr/lib/systemd/system/bootc-fetch-apply-updates.timer
sed -i 's|#AutomaticUpdatePolicy.*|AutomaticUpdatePolicy=stage|' /etc/rpm-ostreed.conf
sed -i 's|#LockLayering.*|LockLayering=true|' /etc/rpm-ostreed.conf

# Enable CRB and install EPEL
dnf install -y 'dnf-command(config-manager)' epel-release
dnf config-manager --set-enabled crb
dnf upgrade -y epel-release

# Exclude some unneeded packages
dnf config-manager --save --setopt=exclude=loupe,PackageKit,PackageKit-command-not-found,rootfiles,firefox,redhat-flatpak-repo

# Install desktop
bash "$(dirname "$0")/desktop.sh"

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

# Final cleanup
dnf clean all
find /var -mindepth 1 -maxdepth 1 ! -path '/var/cache' -delete 2>/dev/null || true
find /var/cache -mindepth 1 ! -path '/var/cache/dnf*' -delete 2>/dev/null || true
mkdir -p /var /boot

# Make /usr/local writeable
ln -s /var/usrlocal /usr/local