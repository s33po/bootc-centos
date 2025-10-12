#!/usr/bin/env bash

set -xeuo pipefail

### Swap stock kernel to pinned Kmods SIG kernel version ###
### Pinning logic to target specific kernel versions adapted from Bluefin-LTS: https://github.com/ublue-os/bluefin-lts ###

# Configuration
ARCH=$(uname -m)
TARGET_MAJOR_MINOR="6.16"

# Capture old kernels before changes
OLD_KERNELS=$(rpm -q kernel 2>/dev/null | sort -V || echo "")

# Add Kmods SIG kernel repository
dnf -y install centos-release-kmods-kernel 'dnf-command(versionlock)'

# Clear any existing versionlocks
dnf versionlock clear

# Find the newest target kernel version
echo "--- Pinning Kernel to ${TARGET_MAJOR_MINOR}.x ---"
TARGET_KERNEL_FULL_VERSION=$(dnf list available kernel --showduplicates | \
    grep "^kernel\.${ARCH}.*${TARGET_MAJOR_MINOR}\." | \
    awk '{print $2}' | sort -V | tail -n 1)

if [ -z "$TARGET_KERNEL_FULL_VERSION" ]; then
    echo "Error: No ${TARGET_MAJOR_MINOR}.x kernel found. Exiting."
    exit 1
fi

KERNEL_VERSION=$(echo "$TARGET_KERNEL_FULL_VERSION" | sed "s/\.${ARCH}$//")
echo "Targeting kernel: ${KERNEL_VERSION}"

# Install kernel packages (kmods does not provide modules-extra)
INSTALL_PKGS=(
    "kernel-${KERNEL_VERSION}"
    "kernel-core-${KERNEL_VERSION}"
    "kernel-modules-${KERNEL_VERSION}"
    "kernel-tools-${KERNEL_VERSION}"
    "kernel-tools-libs-${KERNEL_VERSION}"
    "kernel-headers-${KERNEL_VERSION}"
)

dnf install --allowerasing -y "${INSTALL_PKGS[@]/%/.${ARCH}}" || { echo "Error: Failed to install kernel packages."; exit 1; }
echo "Installing kernel packages: ${INSTALL_PKGS[@]/%/.${ARCH}}"

echo "New kernel installed: ${KERNEL_VERSION}"

# Install devtools during kernel swap so related packages match new kernel
bash "$(dirname "$0")/10-devtools.sh"

# Versionlock the new kernel and its related packages
KERNEL_PACKAGES=$(rpm -qa | grep -E '^kernel(-core|-modules|-modules-extra|-modules-core|-headers|-tools|-tools-libs|-devel)?-[0-9]')
for pkg in $KERNEL_PACKAGES; do
    echo "Locking package: ${pkg}"
    dnf versionlock add "$pkg" || { echo "Error: Failed to lock ${pkg}"; exit 1; }
done

# Generate module dependencies
depmod -a "${TARGET_KERNEL_FULL_VERSION}"

# Remove old kernel files to free up space
if [ -n "$OLD_KERNELS" ]; then
    for old_kernel in $OLD_KERNELS; do
        old_version="${old_kernel#kernel-}"
        if [[ "$old_version" != "$KERNEL_VERSION" ]]; then
            echo "Removing old kernel files for $old_version"
            find /lib/modules /usr/lib/modules -mindepth 1 -maxdepth 1 -type d \
                -name "${old_version}*" -exec rm -rf {} + 2>/dev/null || true
        fi
    done
fi

# Disable Kmods repositories after kernel swap
dnf config-manager --set-disabled "centos-kmods-kernel" || true

echo "===== Kernel ${KERNEL_VERSION} installed, set as default, and locked ====="