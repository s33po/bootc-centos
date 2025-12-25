#!/usr/bin/env bash

set -xeuo pipefail

# Disable lastlog display
authselect enable-feature with-silent-lastlog

# Add Justfile to image
install -Dm644 /ctx/build_files/user.just /usr/share/just/user.just

# Create global alias for user.just commands
echo "alias jmain='just --justfile /usr/share/just/user.just'" > /etc/profile.d/jmain.sh
chmod 644 /etc/profile.d/jmain.sh

# Write firewalld zone "Workstation"
mkdir -p /usr/lib/firewalld/zones
cat > /usr/lib/firewalld/zones/Workstation.xml <<EOF
<?xml version="1.0" encoding="utf-8"?>
<zone>
  <short>Workstation</short>
  <description>Incoming connections are restricted to specific services like SMB and DHCPv6.
  All other unsolicited incoming connections are rejected. Only outgoing connections
  are allowed, and only responses to outgoing connections are accepted.</description>
  <service name="dhcpv6-client"/>
  <service name="samba-client"/>
</zone>
EOF

# Set default firewalld zone to "Workstation"
firewall-offline-cmd --set-default-zone=Workstation

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
