#!/usr/bin/env bash

set -xeuo pipefail

# Install minimal set of packages for virtualization support
dnf -y install --setopt=install_weak_deps=False \
    libvirt-daemon \
    libvirt-client \
    libvirt-daemon-kvm \
    virt-install \
   
# Virtual Machine Manager for GUI management
dnf -y install \
    virt-manager

# For more comprehensive virtualization support
#dnf -y group install "Virtualization Host"

# Enable libvirtd
systemctl enable libvirtd