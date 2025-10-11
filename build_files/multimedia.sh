#!/usr/bin/env bash

set -xeuo pipefail

echo "::group::🎬 NON-FREE MULTIMEDIA"

# Add Negativo17 for multimedia codecs
dnf config-manager --add-repo=https://negativo17.org/repos/epel-multimedia.repo
dnf config-manager --set-disabled epel-multimedia

# Install non-free multimedia codecs and plugins
dnf -y install --enablerepo=epel-multimedia --skip-broken \
    ffmpeg \
    libavcodec \
    @multimedia \
    gstreamer1-plugins-bad-free \
    gstreamer1-plugins-bad-free-libs \
    gstreamer1-plugins-good \
    gstreamer1-plugins-base \
    gstreamer1-plugin-vaapi \
    gstreamer1-plugin-libav \
    lame \
    lame-libs \
    libjxl \
    ffmpegthumbnailer \
    libheif \
    libwebp \
    gdk-pixbuf2-modules-extra \
    webp-pixbuf-loader \
    avif-pixbuf-loader

echo "::endgroup::"