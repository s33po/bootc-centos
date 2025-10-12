#!/usr/bin/env bash

set -xeuo pipefail

### Swap stock kernel to newer Kmods SIG LTS kernel ###

# Configuration
ARCH=$(uname -m)

# Capture old kernels before changes
OLD_KERNELS=$(rpm -q kernel 2>/dev/null | sort -V || echo "")

# Clear any existing versionlocks
dnf versionlock clear

# Add Kmods SIG LTS kernel repository (6.18 LTS)
dnf -y install centos-release-kmods-kernel-6.18

# Install the latest LTS kernel and matching tools
# Use noscripts to avoid failing initramfs scriptlets (we generate initramfs later manually)
dnf -y install --setopt=tsflags=noscripts kernel 
dnf -y install kernel-tools kernel-tools-libs kernel-headers

# Get the newly installed kernel version
NEW_KERNEL=$(rpm -q kernel | sort -V | tail -n1)
KERNEL_VERSION=${NEW_KERNEL#kernel-}

echo "New LTS kernel installed: ${KERNEL_VERSION}"

# Install devtools during kernel swap so related packages match new kernel
bash "$(dirname "$0")/10-devtools.sh"

# Versionlock the new kernel and its related packages
dnf versionlock add "${NEW_KERNEL}"
KERNEL_PACKAGES=$(rpm -qa | grep -E '^kernel(-core|-modules|-modules-extra|-modules-core|-headers|-tools|-tools-libs|-devel)?-[0-9]')
for pkg in $KERNEL_PACKAGES; do
    dnf versionlock add "$pkg"
done

# Generate module dependencies for the new kernel
depmod -a "${KERNEL_VERSION}"

# Remove old kernel files to free up space
if [ -n "$OLD_KERNELS" ]; then
    for old_kernel in $OLD_KERNELS; do
        if [[ "$old_kernel" != "$NEW_KERNEL" ]]; then
            echo "Removing old kernel files for $old_kernel"
            find /lib/modules /usr/lib/modules -mindepth 1 -maxdepth 1 -type d \
                -name "${old_kernel#kernel-}*" -exec rm -rf {} + 2>/dev/null || true
        fi
    done
fi

# Disable Kmods LTS repositories after kernel swap
dnf config-manager --set-disabled centos-kmods-kernel-6.18

echo "===== LTS Kernel ${KERNEL_VERSION} installed, set as default, and locked ====="