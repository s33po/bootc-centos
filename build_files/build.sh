#!/usr/bin/env bash

set -euox pipefail

dnf remove -y subscription-manager

dnf install -y 'dnf-command(config-manager)' epel-release
dnf config-manager --set-enabled crb
dnf upgrade -y epel-release

# Install "Workstation"
dnf -y group install "Workstation"

# Install basic support for thumbnailing, wallpapers and image previews
dnf -y install --skip-broken --setopt=install_weak_deps=False \
    avif-pixbuf-loader \
    gdk-pixbuf2-modules-extra \
    jxl-pixbuf-loader \
    libjxl \
    webp-pixbuf-loader

# Install stuff
dnf -y install \
	container-tools \
	systemd-container \
	system-reinstall-bootc \
	btop \
	nvtop \
	distrobox \
	fuse \
	fastfetch \
	just \
	steam-devices \
	zsh \
	fzf \
	tmux \
	fpaste \
    jetbrains-mono-fonts

# Install VSCode
dnf config-manager --add-repo "https://packages.microsoft.com/yumrepos/vscode"
dnf config-manager --set-disabled packages.microsoft.com_yumrepos_vscode
dnf -y --enablerepo packages.microsoft.com_yumrepos_vscode --nogpgcheck  install code

systemctl enable gdm.service
systemctl set-default graphical.target

# Configure AMD GPU kernel parameters for SMU version mismatch compatibility
# Start with minimal parameters to fix boot hang
#mkdir -p /usr/lib/bootc/kargs.d
#cat > /usr/lib/bootc/kargs.d/20-amdgpu.toml << 'EOF'
# Primary fix for SMU version mismatch boot hang
#kargs = ["amdgpu.runpm=0"]
#EOF

# Alternative approaches - uncomment if minimal fix doesn't work:

# Option 1: Runtime PM with delayed initialization (less power impact)
# cat > /usr/lib/bootc/kargs.d/20-amdgpu.toml << 'EOF'  
# kargs = ["amdgpu.runpm=1", "amdgpu.runpm_delay=5000"]
# EOF

# Option 2: More aggressive compatibility parameters
cat > /usr/lib/bootc/kargs.d/20-amdgpu.toml << 'EOF'
kargs = ["amdgpu.runpm=0", "amdgpu.dpm=1", "amdgpu.si_support=1", "amdgpu.cik_support=1"]
EOF

# Option 3: Most aggressive - if all else fails
# cat > /usr/lib/bootc/kargs.d/20-amdgpu.toml << 'EOF'
# kargs = ["amdgpu.runpm=0", "amdgpu.dpm=0", "amdgpu.si_support=1", "amdgpu.cik_support=1", "amdgpu.modeset=1", "amdgpu.dc=0"]
# EOF

# Add Flathub
mkdir -p /etc/flatpak/remotes.d
curl --retry 3 -o /etc/flatpak/remotes.d/flathub.flatpakrepo "https://dl.flathub.org/repo/flathub.flatpakrepo"

# Disable lastlog display 
authselect enable-feature with-silent-lastlog

dnf clean all
find /var -mindepth 1 -maxdepth 1 ! -path '/var/cache' -delete 2>/dev/null || true
find /var/cache -mindepth 1 ! -path '/var/cache/dnf*' -delete 2>/dev/null || true
mkdir -p /var /boot

# Make /usr/local writeable
ln -s /var/usrlocal /usr/local