#!/usr/bin/env bash

set -xeuo pipefail

# Remove subscription-manager, install EPEL and enable CRB
dnf -y remove subscription-manager
dnf config-manager --set-enabled crb
dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-10.noarch.rpm

# Set global dnf options
dnf config-manager --save \
    --setopt=max_parallel_downloads=10

# These are needed to remove intel microcode and nfs-utils..
mkdir -p /var/lib/rpm-state
touch /var/lib/rpm-state/microcode_ctl_un_{intel-ucode,ucode_caveats,file_list}
touch /var/lib/rpm-state/nfs-server.cleanup

# Remove unnecessary firmware and packages
dnf -y remove \
    atheros-firmware \
    brcmfmac-firmware \
    cirrus-audio-firmware \
    intel-audio-firmware \
    intel-gpu-firmware \
    mt7xxx-firmware \
    nfs-{utils,server} \
    nvidia-gpu-firmware \
    nxpwireless-firmware \
    realtek-firmware \
    tiwilink-firmware \
    adcli \
    console-login-helper-messages \
    irqbalance \
    insights-core \
    microcode_ctl \
    sos \
    sssd* \
    toolbox \
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
    mtr \
    qemu-guest-agent \
    rsync \
    strace \
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
