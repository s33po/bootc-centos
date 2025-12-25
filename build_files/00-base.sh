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

# Remove unnecessary firmware
dnf -y remove \
    atheros-firmware \
    brcmfmac-firmware \
    iwlegacy-firmware \
    iwlwifi-dvm-firmware \
    iwlwifi-mvm-firmware \
    mt7xxx-firmware \
    nxpwireless-firmware \
    realtek-firmware \
    tiwilink-firmware \
    intel-gpu-firmware \
    nvidia-gpu-firmware

# Remove unnecessary packages
dnf -y remove \
      console-login-helper-messages \
      chrony \
      sssd* \

# Set global dnf options
dnf config-manager --save \
    --setopt=max_parallel_downloads=10 \
    --setopt=exclude="\
        PackageKit,\
        PackageKit-command-not-found,\
        rootfiles,\
        redhat-flatpak-repo,\
        rsyslog*,\
        console-login-helper-messages,\
        cockpit,\
        chrony,\
        cronie*,\
        crontabs,\
        setroubleshoot,\
        sssd*,\
        firefox,\
        glibc-all-langpacks,\
        ibus-typing-booster,\
        cldr-emoji-annotation,\
        plasma-discover-kns,\
        plasma-discover-packagekit,\
        plasma-workspace-wallpapers,\
        plasma-welcome,\
        xwaylandvideobridge,\
        nvidia-gpu-firmware,\
        intel-gpu-firmware,\
        iwlwifi-dvm-firmware
    "

# Install packages
dnf -y install \
    cifs-utils \
    distrobox \
    firewalld \
    fuse \
    git-core \
    system-reinstall-bootc \
    systemd-container \
    systemd-timesyncd \
    systemd-resolved \
    tuned \
    tuned-ppd

dnf -y install \
    bash-color-prompt \
    bc \
    dos2unix \
    man-pages \
    mtr \
    parted \
    plocate \
    rsync \
    time \
    tree \
    vim \
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
