#!/usr/bin/env bash

set -xeuo pipefail

# Final cleanup
dnf clean all

find /var -mindepth 1 -type f -delete
find /boot -mindepth 1 -delete
find /tmp -mindepth 1 -delete
