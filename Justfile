# Justfile for local building/testing

image_name := "bootc-centos"
tag := env_var_or_default("TAG", "latest")

[private]
default:
    @just --list

# Build image
build:
    #!/usr/bin/env bash
    set -euo pipefail
    podman build --pull=newer --no-cache -t {{ image_name }}:{{ tag }} .

# Build qcow2 for VM
build-vm:
    #!/usr/bin/env bash
    set -euo pipefail

    # Ensure container image exists
    if ! podman image exists "localhost/{{ image_name }}:{{ tag }}"; then
        echo "Container image not found. Building first..."
        just build
    fi

    # Copy image to root podman storage for BIB to use
    sudo podman image scp $(id -u)@localhost::localhost/{{ image_name }}:{{ tag }} root@localhost::localhost/{{ image_name }}:{{ tag }}

    mkdir -p output
    sudo rm -rf output/qcow2 || true

    sudo podman run \
        --rm \
        -it \
        --privileged \
        --pull=newer \
        --security-opt label=type:unconfined_t \
        -v "./bib-config.toml:/config.toml:ro" \
        -v "./output:/output" \
        -v "/var/lib/containers/storage:/var/lib/containers/storage" \
        "quay.io/centos-bootc/bootc-image-builder:latest" \
        --type qcow2 \
        --chown "$(id -u):$(id -g)" \
        "localhost/{{ image_name }}:{{ tag }}"

    echo "VM image built"

# Build ISO
build-iso:
    #!/usr/bin/env bash
    set -euo pipefail

    REMOTE_IMAGE="ghcr.io/s33po/{{ image_name }}:{{ tag }}"
    sudo podman pull "${REMOTE_IMAGE}"

    mkdir -p output
    sudo rm -rf output/iso || true

    # Generate ISO config
    ISO_CONFIG="$(mktemp)"
    export TARGET_IMAGE="${REMOTE_IMAGE}"
    envsubst < "./bib-iso-config.toml" > "${ISO_CONFIG}"

    sudo podman run \
        --rm \
        -it \
        --privileged \
        --pull=newer \
        --security-opt label=type:unconfined_t \
        -v "${ISO_CONFIG}:/config.toml:ro" \
        -v "./output:/output" \
        -v "/var/lib/containers/storage:/var/lib/containers/storage" \
        "quay.io/centos-bootc/bootc-image-builder:latest" \
        --type iso \
        --chown "$(id -u):$(id -g)" \
        --use-librepo=True \
        "${REMOTE_IMAGE}"

    # Clean up temporary ISO config
    rm -f "${ISO_CONFIG}"

    echo "ISO built"

# Clean build artifacts, built and dangling images and podman root storage
clean:
    #!/usr/bin/env bash
    set -euo pipefail

    # Remove output directory
    sudo rm -rf ./output || true

    # Clean built and dangling images
    podman rmi localhost/bootc-centos
    podman image prune -f || true

    # Clean podman root storage
    sudo podman image prune -a -f || true

    # Clean BIB cache directories
    sudo rm -rf /tmp/osbuild-* 2>/dev/null || true
    sudo rm -rf /var/tmp/osbuild-* 2>/dev/null || true

    echo "Cleanup complete!"

# Format Just files (check and auto-fix)
format:
    #!/usr/bin/env bash
    set -euo pipefail

    # Check and format a justfile
    format_file() {
        local file="$1"
        echo "Checking $file..."
        if ! just --unstable --fmt --check -f "$file" 2>/dev/null; then
            echo "Formatting $file"
            just --unstable --fmt -f "$file"
        else
            echo "Already formatted"
        fi
    }

    # Process all .just files
    find . -type f -name "*.just" | while read -r file; do
        format_file "$file"
    done

    # Process Justfile
    format_file "Justfile"
