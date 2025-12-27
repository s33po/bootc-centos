#!/usr/bin/env bash

set -xeuo pipefail

# Add Flathub
mkdir -p /etc/flatpak/remotes.d
curl --retry 3 -o /etc/flatpak/remotes.d/flathub.flatpakrepo "https://dl.flathub.org/repo/flathub.flatpakrepo"

# Add default flatpaks to defpaks.list
tee /etc/flatpak/defpaks.list <<EOF
org.fooyin.fooyin
org.kde.filelight
org.kde.kcalc
org.kde.okular
org.kde.gwenview
org.kde.haruna
org.gtk.Gtk3theme.Breeze
org.mozilla.firefox
org.libreoffice.LibreOffice
io.github.DenysMb.Kontainer
io.podman_desktop.PodmanDesktop
EOF

# Add gaming flatpaks to gaming.list
tee /etc/flatpak/gaming.list <<EOF
com.valvesoftware.Steam
com.valvesoftware.Steam.CompatibilityTool.Proton-GE
EOF
