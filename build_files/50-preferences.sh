#!/usr/bin/env bash

set -xeuo pipefail

###### BASIC PREFERENCES AND TWEAKS ######

# Disable lastlog display
authselect enable-feature with-silent-lastlog

# Configure bootc updates
sed -i 's|^ExecStart=.*|ExecStart=/usr/bin/bootc update --quiet|' /usr/lib/systemd/system/bootc-fetch-apply-updates.service
sed -i 's|^OnUnitInactiveSec=.*|OnUnitInactiveSec=7d\nPersistent=true|' /usr/lib/systemd/system/bootc-fetch-apply-updates.timer
sed -i 's|#AutomaticUpdatePolicy.*|AutomaticUpdatePolicy=stage|' /etc/rpm-ostreed.conf

###### JUST CONFIGURATION ######

# Copy Justfile to image
install -Dm644 /run/context/build_files/user.just /usr/share/just/user.just

# Create global alias for user.just commands
echo "alias jmain='just --justfile /usr/share/just/user.just'" > /etc/profile.d/jmain.sh
chmod 644 /etc/profile.d/jmain.sh

###### FIREWALL CONFIGURATION ######

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

###### Fedora related KDE cleanup ######

# Remove Fedora Plasma look-and-feel
rm -rf /usr/share/plasma/look-and-feel/org.fedoraproject.fedora.desktop

# Update default KDE profile to use Breeze Dark
sed -i \
    's,org.fedoraproject.fedora.desktop,org.kde.breezedark.desktop,g' \
    /usr/share/kde-settings/kde-profile/default/xdg/kdeglobals

# Set SDDM theme to Breeze
sed -i \
    's,#Current=01-breeze-fedora,Current=breeze,g' \
    /etc/sddm.conf

# Remove Fedora wallpapers
rm -rf /usr/share/wallpapers/Fedora
rm -rf /usr/share/wallpapers/F4*
rm -rf /usr/share/backgrounds/f4*

# Remove console login helper messages
dnf remove -y console-login-helper-messages
