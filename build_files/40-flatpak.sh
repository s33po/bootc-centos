#!/usr/bin/env bash

set -xeuo pipefail

# Add Flathub
mkdir -p /etc/flatpak/remotes.d
curl --retry 3 -o /etc/flatpak/remotes.d/flathub.flatpakrepo "https://dl.flathub.org/repo/flathub.flatpakrepo"

# Add default flatpaks to defpaks.list
tee /etc/flatpak/defpaks.list <<EOF
org.mozilla.firefox
org.atheme.audacious
org.kde.gwenview
io.github.DenysMb.Kontainer
org.kde.haruna
org.gnome.Boxes
org.libreoffice.LibreOffice
it.mijorus.gearlever
EOF

# Add gaming flatpaks to gaming.list
tee /etc/flatpak/gaming.list <<EOF
com.valvesoftware.Steam
com.valvesoftware.Steam.CompatibilityTool.Proton-GE
EOF
