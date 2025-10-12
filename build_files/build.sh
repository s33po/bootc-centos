#!/usr/bin/env bash

set -xeuo pipefail

CONTEXT_PATH="$(realpath "$(dirname "$0")/..")"
BUILD_SCRIPTS_PATH="$(realpath "$(dirname "$0")")"

## This script is made to be modular so you can exclude certain scripts as needed.
## For example, if you don't want to swap the kernel, exclude ALL kernel swap scripts.
## If you don't want to install non-free multimedia packages, exclude the multimedia script etc.

# List of scripts to EXCLUDE
EXCLUDE=(
    "05-kernel-hsk.sh"
    "05-kernel-kmods-pin.sh"
    "05-kernel-kmods-lts.sh"
    "11-virtualization.sh"
    "25-multimedia.sh"
    "31-vscode.sh"
    "32-docker.sh"
)

# Copy files from system_files if the directory exists
if [ -d "${CONTEXT_PATH}/system_files" ]; then
    printf "::group:: ===== Copying files =====\n"
    cp -avf "${CONTEXT_PATH}/system_files/." /
    printf "::endgroup::\n"
fi

for script in $(find "${BUILD_SCRIPTS_PATH}" -maxdepth 1 -iname "*-*.sh" -type f | sort --sort=human-numeric); do
  base=$(basename "$script")
  # Check if script is in EXCLUDE array
  if [[ " ${EXCLUDE[@]} " =~ " ${base} " ]]; then
    continue
  fi
  # Skip devtools if any kernel script will run (they call devtools themselves)
  if [[ "$base" == "10-devtools.sh" ]]; then
    for kernel_script in "${BUILD_SCRIPTS_PATH}"/05-kernel-*.sh; do
      if [ -f "$kernel_script" ] && [[ ! " ${EXCLUDE[@]} " =~ " $(basename "$kernel_script") " ]]; then
        continue 2  # Skip devtools and continue outer loop
      fi
    done
  fi
  printf "::group:: ===== ${base} =====\n"
  if command -v /usr/bin/time >/dev/null 2>&1; then
      /usr/bin/time -f "\n===== ::notice::[TIME] %C took %E =====\n" "$(realpath "$script")"
  else
      "$(realpath "$script")"
  fi
  printf "::endgroup::\n"
done
# Make sure cleanup runs last
printf "::group:: ===== Image Cleanup =====\n"
/usr/bin/time -f "\n===== ::notice::[TIME] %C took %E =====\n" "${BUILD_SCRIPTS_PATH}/cleanup.sh"
printf "::endgroup::\n"