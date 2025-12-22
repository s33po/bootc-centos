#!/usr/bin/env bash

set -xeuo pipefail

# Disable lastlog display
authselect enable-feature with-silent-lastlog

# Configure bootc updates
sed -i 's|^ExecStart=.*|ExecStart=/usr/bin/bootc update --quiet|' \
  /usr/lib/systemd/system/bootc-fetch-apply-updates.service

sed -i 's|^OnUnitInactiveSec=.*|OnUnitInactiveSec=7d|' \
  /usr/lib/systemd/system/bootc-fetch-apply-updates.timer

sed -i 's|^#\?Persistent=.*|Persistent=true|' \
  /usr/lib/systemd/system/bootc-fetch-apply-updates.timer

sed -i 's|^#\?AutomaticUpdatePolicy=.*|AutomaticUpdatePolicy=stage|' \
  /etc/rpm-ostreed.conf

# Copy Justfile to image
install -Dm644 /run/context/build_files/user.just /usr/share/just/user.just

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

# Remove console login helper messages
dnf remove -y console-login-helper-messages

# Remove offline docs
rm -rf /usr/share/doc

# Remove Fedora Plasma look-and-feel
rm -rf /usr/share/plasma/look-and-feel/org.fedoraproject.{fedora,fedoralight,fedoradark}.desktop
rm -rf /usr/share/sddm/themes/01-breeze-fedora

# Remove Fedora wallpapers
rm -rf /usr/share/wallpapers/Fedora
rm -rf /usr/share/wallpapers/F4*
rm -rf /usr/share/backgrounds/f4*

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

# Locale pruning to make image smaller: keep EN + FI + essentials
keep_locales=(en en_US en_GB fi fi_FI C POSIX)
keep_files=(locale.alias i18n)

set +x

# Remove large script locales except EN/FI
find /usr/share/locale -type f -path "*/LC_SCRIPTS/ki18n6/*" \
    ! -path "*/en/*" ! -path "*/fi/*" -delete >/dev/null 2>&1 || true

# Remove unwanted locale dirs
for loc in /usr/share/locale/*; do
    [ -d "$loc" ] || continue
    base="$(basename "$loc")"
    if [[ ! " ${keep_locales[*]} " =~ " ${base} " ]]; then
        rm -rf "$loc" >/dev/null 2>&1 || true
    fi
done

# Remove unwanted standalone files
for f in /usr/share/locale/*; do
    [ -f "$f" ] || continue
    base="$(basename "$f")"
    if [[ ! " ${keep_files[*]} " =~ " ${base} " ]]; then
        rm -f "$f" >/dev/null 2>&1 || true
    fi
done
