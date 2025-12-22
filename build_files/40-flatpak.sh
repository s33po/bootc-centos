#!/usr/bin/env bash

set -xeuo pipefail

# Install flatpak
dnf install -y flatpak

# Add Flathub
mkdir -p /etc/flatpak/remotes.d
curl --retry 3 -o /etc/flatpak/remotes.d/flathub.flatpakrepo "https://dl.flathub.org/repo/flathub.flatpakrepo"

# Add default flatpaks to defpaks.list
tee /etc/flatpak/defpaks.list <<EOF
org.atheme.audacious
org.kde.okular
org.kde.gwenview
org.kde.haruna
org.gtk.Gtk3theme.Breeze
org.mozilla.firefox
org.libreoffice.LibreOffice
io.github.DenysMb.Kontainer
EOF

# Add gaming flatpaks to gaming.list
tee /etc/flatpak/gaming.list <<EOF
com.valvesoftware.Steam
com.valvesoftware.Steam.CompatibilityTool.Proton-GE
EOF
