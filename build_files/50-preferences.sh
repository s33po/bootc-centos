#!/usr/bin/env bash

set -xeuo pipefail

# Disable lastlog display
authselect enable-feature with-silent-lastlog

# Remove console login helper messages
dnf remove -y console-login-helper-messages

# Add Justfile to image
install -Dm644 /ctx/build_files/user.just /usr/share/just/user.just

# Create global alias for user.just commands
echo "alias jmain='just --justfile /usr/share/just/user.just'" > /etc/profile.d/jmain.sh
chmod 644 /etc/profile.d/jmain.sh

# Change Plasma defaults
sed -i 's|^LookAndFeelPackage=.*|LookAndFeelPackage=org.kde.breezedark.desktop|' \
  /usr/share/kde-settings/kde-profile/default/xdg/kdeglobals

sed -i 's|^ColorScheme=.*|ColorScheme=BreezeDark|' \
  /usr/share/kde-settings/kde-profile/default/xdg/kdeglobals

# SDDM config
sed -i 's|^#\?Current=.*|Current=breeze|' \
  /etc/sddm.conf

sed -i 's|^background=.*/images/|background=/usr/share/wallpapers/Next/contents/images_dark/|' \
  /usr/share/sddm/themes/breeze/theme.conf
