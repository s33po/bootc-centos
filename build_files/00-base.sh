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
        PackageKit,PackageKit-command-not-found,plasma-discover-packagekit,\
        plasma-workspace-wallpapers,redhat-flatpak-repo,setroubleshoot,firefox,glibc-all-langpacks,\
        plasma-welcome,xwaylandvideobridge
    "
# Configure bootc updates
sed -i 's|^ExecStart=.*|ExecStart=/usr/bin/bootc update --quiet|' \
  /usr/lib/systemd/system/bootc-fetch-apply-updates.service

sed -i 's|^OnUnitInactiveSec=.*|OnUnitInactiveSec=7d|' \
  /usr/lib/systemd/system/bootc-fetch-apply-updates.timer

sed -i 's|^#\?Persistent=.*|Persistent=true|' \
  /usr/lib/systemd/system/bootc-fetch-apply-updates.timer

sed -i 's|^#\?AutomaticUpdatePolicy=.*|AutomaticUpdatePolicy=stage|' \
  /etc/rpm-ostreed.conf
