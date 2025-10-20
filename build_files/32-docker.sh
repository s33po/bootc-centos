#!/usr/bin/env bash

set -xeuo pipefail

# Install Docker from official Docker repository
dnf config-manager --add-repo "https://download.docker.com/linux/centos/docker-ce.repo"
dnf config-manager --set-disabled docker-ce-stable
dnf -y --enablerepo docker-ce-stable install --setopt=install_weak_deps=False \
	docker-ce \
	docker-ce-cli \
    docker-model-plugin \
	containerd.io \
	docker-buildx-plugin \
	docker-compose-plugin

### Docker related setup/configuration ###

# Create symlink for docker-compose command
ln -s /usr/libexec/docker/cli-plugins/docker-compose /usr/bin/docker-compose

# Ensure sysctl directory exists
mkdir -p /usr/lib/sysctl.d

# Enable IP forwarding for Docker networking
echo "net.ipv4.ip_forward = 1" >/usr/lib/sysctl.d/docker-ce.conf

# Disable Docker from starting by default in systemd presets
sed -i 's/enable docker/disable docker/' /usr/lib/systemd/system-preset/90-default.preset

# Preset Docker services to their default states
systemctl preset docker.service docker.socket

# Create docker group configuration for sysusers
cat >/usr/lib/sysusers.d/docker.conf <<'EOF'
g docker -
EOF