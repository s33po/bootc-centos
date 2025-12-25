#!/usr/bin/env bash

set -xeuo pipefail

# Enable services
systemctl enable systemd-resolved.service
systemctl enable systemd-timesyncd
systemctl enable sddm.service
systemctl enable bootc-fetch-apply-updates.timer
systemctl enable firewalld
systemctl enable podman.socket

# Disable services
systemctl disable cockpit.socket
systemctl disable rpm-ostree-countme.timer
