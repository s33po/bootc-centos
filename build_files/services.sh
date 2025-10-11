#!/usr/bin/env bash

set -xeuo pipefail

echo "::group::🧩 SERVICES ENABLE/DISABLE"

# Enable services
systemctl enable gdm.service
systemctl enable bootc-fetch-apply-updates.timer
systemctl enable firewalld
systemctl enable podman.socket

# Disable services
systemctl disable cockpit.socket
systemctl disable rpm-ostree-countme.timer

echo "::endgroup::"