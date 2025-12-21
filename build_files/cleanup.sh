#!/usr/bin/env bash

set -xeuo pipefail

# Final cleanup
dnf clean all
find /var -mindepth 1 -delete
find /boot -mindepth 1 -delete
mkdir -p /var /boot

# Remove just docs so ISOs work...
rm -rf /usr/share/doc/just/* >/dev/null 2>&1 || true

# Make /usr/local writeable
ln -s /var/usrlocal /usr/local
