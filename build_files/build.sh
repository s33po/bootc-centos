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
mkdir -p /usr/lib/bootc/kargs.d
cat > /usr/lib/bootc/kargs.d/20-amdgpu.toml << 'EOF'
kargs = ["amdgpu.runpm=0", "amdgpu.dpm=1", "amdgpu.si_support=1", "amdgpu.cik_support=1", "amdgpu.runpm_delay=5000"]
EOF

# Additional SMU version mismatch fixes
cat > /usr/lib/bootc/kargs.d/21-amd-smu.toml << 'EOF'
# SMU firmware version tolerance
kargs = ["amdgpu.smu_memory_pool_size=0", "amdgpu.gpu_recovery=0"]
EOF

# IOMMU/PCIe timing fix for AMD systems
cat > /usr/lib/bootc/kargs.d/22-iommu.toml << 'EOF'
# AMD IOMMU configuration for stability
kargs = ["amd_iommu=on", "iommu=pt"]
EOF

# Force early AMD GPU module loading to avoid race conditions
mkdir -p /etc/modules-load.d
echo "amdgpu" > /etc/modules-load.d/amdgpu.conf

# GDM delay to ensure GPU is fully initialized
mkdir -p /etc/systemd/system/gdm.service.d
cat > /etc/systemd/system/gdm.service.d/99-delay.conf << 'EOF'
[Unit]
After=multi-user.target
After=graphical-session-pre.target

[Service]
ExecStartPre=/bin/sleep 3
EOF

# Fix sysusers issues that can cause boot hangs after GPU init
mkdir -p /etc/systemd/system/systemd-sysusers.service.d
cat > /etc/systemd/system/systemd-sysusers.service.d/99-bootc-fix.conf << 'EOF'
[Unit]
# Ensure sysusers runs after filesystem is properly mounted
After=local-fs.target
After=systemd-remount-fs.service

[Service]
# Add timeout and restart on failure
TimeoutSec=30
Restart=on-failure
RestartSec=2
EOF

# Add to kargs for detailed boot logging
cat > /usr/lib/bootc/kargs.d/99-debug.toml << 'EOF'
kargs = ["systemd.log_level=debug", "systemd.log_target=console"]
EOF

# Alternative: Disable problematic sysusers entirely for graphics users
# systemctl mask systemd-sysusers.service

# Fix auditd.service issues that cause boot hangs in bootc
# auditd often fails due to read-only filesystem constraints
mkdir -p /etc/systemd/system/auditd.service.d
cat > /etc/systemd/system/auditd.service.d/99-bootc-fix.conf << 'EOF'
[Unit]
# Reduce auditd dependencies that can cause hangs
After=local-fs.target
ConditionPathExists=/var/log/audit

[Service]
# Add timeout and allow failure without hanging boot
TimeoutSec=15
TimeoutStartSec=15
Restart=no
ExecStartPre=/bin/mkdir -p /var/log/audit
ExecStartPre=/bin/chmod 755 /var/log/audit
EOF

# Alternative: Disable auditd entirely if it keeps hanging
# systemctl disable auditd.service
# systemctl mask auditd.service

# Ensure audit log directory exists with correct permissions
mkdir -p /var/log/audit
chmod 755 /var/log/audit

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