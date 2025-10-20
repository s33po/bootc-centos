#!/usr/bin/env bash

set -xeuo pipefail

# Install non-free multimedia codecs and plugins from Negativo17
# Flatpak apps have their own codecs and plugins bundled so this is mainly for
# thumbnailing and apps you may install to the base image during the build.

# Add Negativo17 for multimedia codecs
dnf config-manager --add-repo=https://negativo17.org/repos/epel-multimedia.repo

# Install non-free multimedia codecs and plugins
dnf -y install --skip-broken \
    @multimedia \
    ffmpeg \
    libavcodec \
    gstreamer1-plugins-bad-free-libs \
    gstreamer1-plugins-base \
    gstreamer1-plugin-vaapi \
    gstreamer1-plugin-libav \
    lame \
    lame-libs \
    ffmpegthumbnailer \
    libheif

# Disable Negativo17 repo after multimedia install
dnf config-manager --set-disabled epel-multimedia