#!/usr/bin/env bash

set -xeuo pipefail

echo "::group::⚙️ INITRAMFS GENERATION"

# Configure dracut to include plymouth
mkdir -p /etc/dracut.conf.d
echo 'add_dracutmodules+=" plymouth "' > /etc/dracut.conf.d/plymouth.conf

# Add resume module for hibernation
echo "add_dracutmodules+=\" resume \"" >/etc/dracut.conf.d/resume.conf

# Write plymouthd.conf
mkdir -p /etc/plymouth
cat > /etc/plymouth/plymouthd.conf <<EOF
[Daemon]
Theme=spinner
EOF

# Enable quiet boot with spinner
mkdir -p /usr/lib/bootc/kargs.d
cat > /usr/lib/bootc/kargs.d/plymouth.toml <<EOF
kargs = ["splash", "quiet", "loglevel=3"]
EOF

# Genrerate initramfs
kernel=$(rpm -q kernel | sort -V | tail -n1 | sed 's/^kernel-//')
/usr/bin/dracut --no-hostonly --kver "$kernel" --reproducible --zstd -v \
--add ostree -f "/lib/modules/$kernel/initramfs.img"

echo "::endgroup::"