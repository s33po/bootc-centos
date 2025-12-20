#!/usr/bin/env bash

set -xeuo pipefail

# Final cleanup
dnf clean all

# Clean /var
for d in /var/cache /var/tmp /var/log; do
    find "$d" -mindepth 1 -delete || true
done

find /var -mindepth 1 -maxdepth 1 ! -path '/var/cache' ! -path '/var/tmp' ! -path '/var/log' -delete || true

# Locale pruning: keep EN + FI + essentials
keep_locales=(en en_US en_GB fi fi_FI C POSIX)
keep_files=(locale.alias i18n)

# Remove large script locales except EN/FI
find /usr/share/locale -type f -path "*/LC_SCRIPTS/ki18n6/*" \
    ! -path "*/en/*" ! -path "*/fi/*" -delete || true

# Remove unwanted locale dirs
for loc in /usr/share/locale/*; do
    [ -d "$loc" ] || continue
    base="$(basename "$loc")"
    if [[ ! " ${keep_locales[*]} " =~ " ${base} " ]]; then
        rm -rf "$loc"
    fi
done

# Remove unwanted standalone files
for f in /usr/share/locale/*; do
    base="$(basename "$f")"
    if [[ -f "$f" && ! " ${keep_files[*]} " =~ " ${base} " ]]; then
        rm -f "$f"
    fi
done

# Remove just docs so ISOs work.....
rm -rf /usr/share/doc/just/*
