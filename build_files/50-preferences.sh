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

###### PRE-CLEANUP ######

# Remove console login helper messages
dnf remove -y console-login-helper-messages

# Remove docs to make image smaller
rm -rf /usr/share/doc

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
