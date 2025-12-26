#!/usr/bin/env bash
set -euo pipefail

CONTEXT_PATH="$(realpath "$(dirname "$0")/..")"
BUILD_SCRIPTS_PATH="$(realpath "$(dirname "$0")")"

# Copy files from system_files if the directory exists
if [ -d "${CONTEXT_PATH}/system_files" ]; then
  printf "::group:: ===== Copying files =====\n"
  cp -avf "${CONTEXT_PATH}/system_files/." /
  printf "::endgroup::\n"
fi

# List of build scripts to EXCLUDE
EXCLUDE=(
  "05-kernel-kmods.sh"
  "11-virtualization.sh"
  "25-multimedia.sh"
  "31-vscode.sh"
  "32-docker.sh"
)

printf "::group:: ===== Discovering build scripts =====\n"

# Build list of scripts to execute
scripts_to_run=()

# Discover scripts to execute
for script in $(find "${BUILD_SCRIPTS_PATH}" -maxdepth 1 -iname "*-*.sh" -type f | sort --sort=human-numeric); do
  base=$(basename "$script")

  # Exclude listed scripts
  if [[ " ${EXCLUDE[@]} " =~ " ${base} " ]]; then
    echo "Excluding: $base"
    continue
  fi

  echo "Including: $base"
  scripts_to_run+=("$script")
done

echo "Scripts to execute: ${#scripts_to_run[@]} scripts"
printf "::endgroup::\n"

# Execute scripts
for script in "${scripts_to_run[@]}"; do
  base=$(basename "$script")
  printf "::group:: ===== ${base} =====\n"
  "$(realpath "$script")"
  printf "::endgroup::\n"
done

# Cleanup
printf "::group:: ===== Image Cleanup =====\n"
"${BUILD_SCRIPTS_PATH}/cleanup.sh"
printf "::endgroup::\n"
