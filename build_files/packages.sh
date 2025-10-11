#!/usr/bin/env bash

set -xeuo pipefail

echo "::group::📦 EXTRA PACKAGES"

# Install extra packages
dnf -y install \
	container-tools \
	systemd-container \
	system-reinstall-bootc \
	btop \
	nvtop \
	distrobox \
	fuse \
	fastfetch \
	ntfs-3g \
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

echo "::endgroup::"