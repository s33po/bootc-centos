#!/usr/bin/env bash

set -xeuo pipefail

mkdir -m 0700 -p /var/roothome

# Make /usr/local and /opt mutable
mkdir -p /var/{opt,usrlocal}
rm -rf /opt /usr/local
ln -sf var/opt /opt
ln -sf ../var/usrlocal /usr/local

# Remove subscription-manager, install EPEL and enable CRB
dnf -y remove subscription-manager
dnf config-manager --set-enabled crb
dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-10.noarch.rpm

# Set global dnf options
dnf config-manager --save \
    --setopt=max_parallel_downloads=10

# Remove unnecessary firmware
dnf -y remove \
    atheros-firmware \
    brcmfmac-firmware \
    intel-gpu-firmware \
    mt7xxx-firmware \
    nvidia-gpu-firmware \
    nxpwireless-firmware \
    realtek-firmware \
    tiwilink-firmware

# Remove unnecessary packages
dnf -y remove \
    adcli \
    console-login-helper-messages \
    irqbalance \
    sssd* \
    yggdrasil*

# Install gcc for brew (pulls kernel-headers)
#dnf -y --setopt=install_weak_deps=False install gcc

# Install packages
dnf -y install --setopt=install_weak_deps=False \
    bash-color-prompt \
    bc \
    cifs-utils \
    distrobox \
    firewalld \
    fuse \
    git-core \
    lshw \
    man-pages \
    mtr \
    parted \
    qemu-guest-agent \
    rsync \
    spice-vdagent \
    strace \
    symlinks \
    system-reinstall-bootc \
    systemd-container \
    systemd-resolved \
    time \
    tree \
    tuned \
    tuned-ppd

# Preset and enable resolved
tee /usr/lib/systemd/system-preset/91-resolved-default.preset <<'EOF'
enable systemd-resolved.service
EOF

tee /usr/lib/tmpfiles.d/resolved-default.conf <<'EOF'
L /etc/resolv.conf - - - - ../run/systemd/resolve/stub-resolv.conf
EOF

systemctl preset systemd-resolved.service

# Configure bootc updates
sed -i 's|^ExecStart=.*|ExecStart=/usr/bin/bootc update --quiet|' \
  /usr/lib/systemd/system/bootc-fetch-apply-updates.service

sed -i 's|^OnUnitInactiveSec=.*|OnUnitInactiveSec=3d|' \
  /usr/lib/systemd/system/bootc-fetch-apply-updates.timer

sed -i 's|^#\?Persistent=.*|Persistent=true|' \
  /usr/lib/systemd/system/bootc-fetch-apply-updates.timer

sed -i 's|^#\?AutomaticUpdatePolicy=.*|AutomaticUpdatePolicy=stage|' \
  /etc/rpm-ostreed.conf
