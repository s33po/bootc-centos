#!/usr/bin/env bash

set -xeuo pipefail

# Disable lastlog display
authselect enable-feature with-silent-lastlog

# Add user.just to image
install -Dm644 /ctx/build_files/user.just /usr/share/just/user.just

# Create global alias for user.just commands
echo "alias jmain='just --justfile /usr/share/just/user.just'" > /etc/profile.d/jmain.sh
chmod 644 /etc/profile.d/jmain.sh

# Write firewalld zone "Workstation" (more permissive than stock)
mkdir -p /usr/lib/firewalld/zones
cat > /usr/lib/firewalld/zones/Workstation.xml <<EOF
<?xml version="1.0" encoding="utf-8"?>
<zone>
  <short>Workstation</short>
  <description>Unsolicited incoming network packets are rejected from port 1 to 1024,
except for select network services. Incoming packets that are related to
outgoing network connections are accepted. Outgoing network connections are
allowed.</description>
  <service name="dhcpv6-client"/>
  <service name="ssh"/>
  <service name="samba-client"/>
  <service name="dns"/>
  <port protocol="udp" port="1025-65535"/>
  <port protocol="tcp" port="1025-65535"/>
  <forward/>
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
