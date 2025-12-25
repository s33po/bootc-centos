#!/usr/bin/env bash

set -xeuo pipefail

mkdir -m 0700 -p /var/roothome

# Make /usr/local and /opt mutable
mkdir -p /var/{opt,usrlocal}
rm -rf /opt /usr/local
ln -sf var/opt /opt
ln -sf ../var/usrlocal /usr/local

# Set global dnf options
dnf config-manager --save \
    --setopt=max_parallel_downloads=10

# Remove subscription-manager, install EPEL and enable CRB
dnf -y remove subscription-manager
dnf config-manager --set-enabled crb
dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-10.noarch.rpm

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

dnf -y reinstall nfs-utils chrony irqbalance sssd

# Remove unnecessary packages
dnf -y remove \
    adcli \
    chrony \
    console-login-helper-messages \
    irqbalance \
    nfs-utils \
    sssd* \
    yggdrasil*

# Install packages
dnf -y install --setopt=install_weak_deps=False \
    bash-color-prompt \
    bc \
    cifs-utils \
    distrobox \
    firewalld \
    fuse \
    git-core \
    man-pages \
    mtr \
    parted \
    rsync \
    system-reinstall-bootc \
    systemd-container \
    systemd-resolved \
    systemd-timesyncd \
    time \
    tree \
    tuned \
    tuned-ppd \
    wget

# Enable resolved
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

sed -i 's|^OnUnitInactiveSec=.*|OnUnitInactiveSec=7d|' \
  /usr/lib/systemd/system/bootc-fetch-apply-updates.timer

sed -i 's|^#\?Persistent=.*|Persistent=true|' \
  /usr/lib/systemd/system/bootc-fetch-apply-updates.timer

sed -i 's|^#\?AutomaticUpdatePolicy=.*|AutomaticUpdatePolicy=stage|' \
  /etc/rpm-ostreed.conf
