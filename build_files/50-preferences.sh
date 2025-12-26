#!/usr/bin/env bash

set -xeuo pipefail

# Disable lastlog display
authselect enable-feature with-silent-lastlog

# Copy Justfile to image
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

# Set up dconf system profile
mkdir -p /etc/dconf/profile
cat <<EOF > /etc/dconf/profile/user
user-db:user
system-db:local
EOF

# Set GNOME system-wide defaults
mkdir -p /etc/dconf/db/local.d
cat <<EOF > /etc/dconf/db/local.d/00-gnome
[org/gnome/desktop/interface]
color-scheme='prefer-dark'
clock-format='24h'
clock-show-weekday=true

[org/gnome/desktop/wm/preferences]
button-layout='appmenu:minimize,maximize,close'
center-new-windows=true

[org/gnome/desktop/peripherals/mouse]
accel-profile='flat'

[org/gnome/shell]
enable-hot-corners=false

[org/gnome/settings-daemon/plugins/media-keys/custom-keybindings]
custom-keybindings=['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/']

[org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0]
name='Launch Ptyxis'
binding='<Super>Return'
command='/usr/bin/ptyxis --new-window'

[org/gnome/nautilus/preferences]
sort-directories-first=true
default-folder-viewer='list-view'

[org/gnome/desktop/calendar]
show-weekdate=true
EOF

# Apply dconf settings 
dconf update
