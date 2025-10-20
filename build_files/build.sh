
#!/usr/bin/env bash
set -euo pipefail

# Toggle timing of each script, set false/true to disable/enable
TIME="${TIME:-false}"
# Install 'time' if not present and timing is enabled
if [[ "$TIME" == "true" ]]; then
  if ! command -v /usr/bin/time >/dev/null 2>&1; then
    dnf install -y time
  fi
fi

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
  "05-kernel-hsk.sh"
  "05-kernel-kmods-pin.sh"
  "05-kernel-kmods-lts.sh"
  "11-virtualization.sh"
  "25-multimedia.sh"
  "31-vscode.sh"
  "32-docker.sh"
)

printf "::group:: ===== Discovering build scripts =====\n"

# Build list of scripts to execute
scripts_to_run=()

# Determine if any kernel script will run
kernel_script_will_run=false
for kernel_script in "${BUILD_SCRIPTS_PATH}"/05-kernel-*.sh; do
  base=$(basename "$kernel_script")
  if [ -f "$kernel_script" ] && [[ ! " ${EXCLUDE[@]} " =~ " ${base} " ]]; then
    kernel_script_will_run=true
    break
  fi
done

echo "Kernel script will run: $kernel_script_will_run"
echo "Excluded scripts: ${EXCLUDE[*]}"
echo "Discovering scripts to execute..."

for script in $(find "${BUILD_SCRIPTS_PATH}" -maxdepth 1 -iname "*-*.sh" -type f | sort --sort=human-numeric); do
  base=$(basename "$script")
  # Exclude listed scripts
  if [[ " ${EXCLUDE[@]} " =~ " ${base} " ]]; then
    echo "Excluding: $base"
    continue
  fi
  # Only skip direct execution of devtools if kernel script will run (kernel scripts will run devtools.sh during kernel swap)
  if [[ "$base" == "10-devtools.sh" && "$kernel_script_will_run" == true ]]; then
    echo "Skipping $base (will be run by kernel script)"
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
  if [[ "$TIME" == "true" ]]; then
    /usr/bin/time -f "\n===== ::notice::[TIME] %C took %E =====\n" "$(realpath "$script")"
  else
    "$(realpath "$script")"
  fi
  printf "::endgroup::\n"
done

# Make sure cleanup runs last
printf "::group:: ===== Image Cleanup =====\n"
if [[ "$TIME" == "true" ]]; then
  /usr/bin/time -f "\n===== ::notice::[TIME] %C took %E =====\n" "${BUILD_SCRIPTS_PATH}/cleanup.sh"
else
  "${BUILD_SCRIPTS_PATH}/cleanup.sh"
fi
printf "::endgroup::\n"