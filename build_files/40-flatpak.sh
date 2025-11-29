#!/usr/bin/env bash

set -xeuo pipefail

# Install flatpak
dnf install -y flatpak

# Add Flathub
mkdir -p /etc/flatpak/remotes.d
curl --retry 3 -o /etc/flatpak/remotes.d/flathub.flatpakrepo "https://dl.flathub.org/repo/flathub.flatpakrepo"

# Add default flatpaks to defpaks.list
tee /etc/flatpak/defpaks.list <<EOF
org.kde.gwenview
org.kde.haruna
org.kde.KStyle.Breeze
org.gtk.Gtk3theme.Breeze
org.mozilla.firefox
org.libreoffice.LibreOffice
org.atheme.audacious
io.github.DenysMb.Kontainer
org.freedesktop.Platform.codecs-extra
org.freedesktop.Platform.openh264
EOF

# Add gaming flatpaks to gaming.list
tee /etc/flatpak/gaming.list <<EOF
com.valvesoftware.Steam
com.valvesoftware.Steam.CompatibilityTool.Proton-GE
net.davidotek.pupgui2
EOF
