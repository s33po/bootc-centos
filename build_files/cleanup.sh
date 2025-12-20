#!/usr/bin/env bash

set -xeuo pipefail

# Final cleanup
dnf clean all

# Clean /var safely

for d in /var/cache /var/tmp /var/log; do
    # Only remove contents, leave mount points intact
    find "$d" -mindepth 1 -delete >/dev/null 2>&1 || true
done

# Clean other top-level /var dirs, skip mounts
for d in /var/*; do
    case "$d" in
        /var/cache|/var/tmp|/var/log) continue ;;
    esac
    # Only remove if safe
    rm -rf "$d" >/dev/null 2>&1 || true
done

# Locale pruning: keep EN + FI + essentials
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

set -x

# Remove just docs so ISOs work...
rm -rf /usr/share/doc/just/* >/dev/null 2>&1 || true
