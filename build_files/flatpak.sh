#!/usr/bin/env bash

set -xeuo pipefail

echo "::group::🧊 FLATPAK CONFIG"

# Add Flathub
mkdir -p /etc/flatpak/remotes.d
curl --retry 3 -o /etc/flatpak/remotes.d/flathub.flatpakrepo "https://dl.flathub.org/repo/flathub.flatpakrepo"

# Add default flatpaks to defpaks.list
tee /etc/flatpak/defpaks.list <<EOF
org.mozilla.firefox
org.gnome.Calendar
org.gnome.NautilusPreviewer
org.gnome.Loupe
com.mattjakeman.ExtensionManager
page.tesk.Refine
org.gtk.Gtk3theme.adw-gtk3
org.gtk.Gtk3theme.adw-gtk3-dark
com.github.tchx84.Flatseal
io.github.flattool.Warehouse
com.ranfdev.DistroShelf
org.gnome.Boxes
de.capypara.FieldMonitor
org.gnome.World.PikaBackup
com.github.neithern.g4music
com.github.rafostar.Clapper
org.libreoffice.LibreOffice
it.mijorus.gearlever
be.alexandervanhee.gradia
EOF

echo "::endgroup::"