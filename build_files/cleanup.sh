#!/usr/bin/env bash

set -xeuo pipefail

# Final cleanup
dnf clean all
find /var -mindepth 1 -maxdepth 1 ! -path '/var/cache' -delete 2>/dev/null || true
find /var/cache -mindepth 1 ! -path '/var/cache/dnf*' -delete 2>/dev/null || true
mkdir -p /var /boot

# Make /usr/local writeable
ln -s /var/usrlocal /usr/local