#!/usr/bin/env bash

set -xeuo pipefail

echo "::group::⚙️ KERNEL SWAP KMODS"

### Swap stock kernel to newer Kmods SIG kernel ###

## Script below is mostly FROM Bluefin-LTS: https://github.com/ublue-os/bluefin-lts ##
## I don’t plan to use the pinned mainline kernel long-term and will switch to the next LTS kernel (most likely 6.18) when it becomes available from kmods.

# dnf -y install centos-release-kmods-kernel-6.18
dnf -y install centos-release-kmods-kernel

# Determine architecture and target kernel version
ARCH=$(uname -m)
TARGET_MAJOR_MINOR="6.16"
echo "--- Pinning Kernel to ${TARGET_MAJOR_MINOR}.x ---"

# Find the newest target kernel version
TARGET_KERNEL_FULL_VERSION=$(dnf list available kernel --showduplicates | \
    grep "^kernel.${ARCH}.*${TARGET_MAJOR_MINOR}\." | \
    awk '{print $2}' | sort -V | tail -n 1)

if [ -z "$TARGET_KERNEL_FULL_VERSION" ]; then
    echo "Error: No ${TARGET_MAJOR_MINOR}.x kernel found. Exiting."
    exit 1
fi

KERNEL_VERSION_ONLY=$(echo "$TARGET_KERNEL_FULL_VERSION" | sed "s/\.${ARCH}$//")
echo "Targeting kernel: ${KERNEL_VERSION_ONLY}"

# Install kernel packages (kmods does not provide modules-extra)
INSTALL_PKGS=(
    "kernel-${KERNEL_VERSION_ONLY}"
    "kernel-core-${KERNEL_VERSION_ONLY}"
    "kernel-modules-${KERNEL_VERSION_ONLY}"
)

dnf install --allowerasing -y "${INSTALL_PKGS[@]/%/.${ARCH}}" || { echo "Error: Failed to install kernel packages."; exit 1; }
echo "Installing kernel packages: ${INSTALL_PKGS[@]/%/.${ARCH}}"

# Add versionlocks
for pkg in "${INSTALL_PKGS[@]}"; do
    echo "Locking package: ${pkg}.${ARCH}"
    dnf versionlock add "${pkg}.${ARCH}" || { echo "Error: Failed to lock ${pkg}.${ARCH}."; exit 1; }
done

#Run depmod
depmod -a "${KERNEL_VERSION_ONLY}.${ARCH}"

echo "Kernel ${KERNEL_VERSION_ONLY} installed, set as default, and locked."

# Disable Kmods repositories after kernel swap
dnf config-manager --set-disabled "centos-kmods-kernel" || true

echo "::endgroup::"