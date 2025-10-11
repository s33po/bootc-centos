#!/usr/bin/env bash

set -xeuo pipefail

echo "::group::⚙️ KERNEL SWAP HYPERSCALE"

### Swap stock kernel to newer HyperScale kernel ###

# Capture the old kernel version before installing a new one
old_kernel=$(rpm -q kernel | sort -V)

# Clear any existing versionlocks
dnf versionlock clear

# Add HyperScale kernel repository
dnf -y install centos-release-hyperscale-kernel
 
# Install the latest kernel from HyperScale
dnf install -y --setopt=tsflags=noscripts kernel

# Get the newly installed kernel version
new_kernel=$(rpm -q kernel | sort -V | tail -n1)

# Versionlock the new kernel and its related packages
dnf versionlock add kernel-${new_kernel}
kernel_packages=$(rpm -qa | grep -E '^kernel(-core|-modules|-modules-extra|-modules-core|-headers)?-[0-9]')
for pkg in $kernel_packages; do
    dnf versionlock add "$pkg"
done

# Extract the kernel version without the 'kernel-' prefix for depmod
kernel_version=${new_kernel#kernel-}

# Generate module dependencies for the new kernel
depmod -a ${kernel_version}

# Remove old kernel files to free up space
for old_kernel in $old_kernel; do
  if [[ "$old_kernel" != "$new_kernel" ]]; then
    echo "Removing old kernel files for $old_kernel"
    find /lib/modules /usr/lib/modules -mindepth 1 -maxdepth 1 -type d \
      -name "$old_kernel*" -exec rm -rf {} +
  fi
done

# Disable CentOS Hyperscale repositories after kernel swap
dnf config-manager --set-disabled centos-hyperscale centos-hyperscale-kernel || true

echo "Kernel ${kernel_version} installed, set as default, and locked."

echo "::endgroup::"