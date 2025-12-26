#!/usr/bin/env bash

set -xeuo pipefail

# Remove offline docs
rm -rf /usr/share/doc

# Final cleanup
dnf clean all
find /var -mindepth 1 -delete
find /boot -mindepth 1 -delete
find /tmp -mindepth 1 -delete
