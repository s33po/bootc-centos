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

    echo "Building {{ image_name }}:{{ tag }}..."

    podman build \
        --pull=newer \
        -t "{{ image_name }}:{{ tag }}" \
        .

# Build qcow2 for VM
build-vm:
    #!/usr/bin/env bash
    set -euo pipefail

    echo "Building VM image from localhost/{{ image_name }}:{{ tag }}..."

    # Ensure container image exists
    if ! podman image exists "localhost/{{ image_name }}:{{ tag }}"; then
        echo "Container image not found. Building first..."
        just build
    fi

    # Copy image to root podman storage for BIB to use
    echo "Copying image to root podman storage..."
    sudo podman image scp $(id -u)@localhost::localhost/{{ image_name }}:{{ tag }} root@localhost::localhost/{{ image_name }}:{{ tag }}

    mkdir -p output
    sudo rm -rf output/qcow2 || true

    sudo podman run \
        --rm \
        -it \
        --privileged \
        --pull=newer \
        --security-opt label=type:unconfined_t \
        -v "$(pwd)/bib-config.toml:/config.toml:ro" \
        -v "$(pwd)/output:/output" \
        -v "/var/lib/containers/storage:/var/lib/containers/storage" \
        "quay.io/centos-bootc/bootc-image-builder:latest" \
        --type qcow2 \
        --chown "$(id -u):$(id -g)" \
        --local \
        "localhost/{{ image_name }}:{{ tag }}"

    echo "VM image built: output/qcow2/disk.qcow2"
    
    # Auto-cleanup: Remove the copied image from root storage
    echo "Cleaning up root storage..."
    sudo podman rmi "localhost/{{ image_name }}:{{ tag }}" 2>/dev/null || true

# Build ISO installer
build-iso:
    #!/usr/bin/env bash
    set -euo pipefail

    echo "Building ISO installer..."

    # Ensure container image exists and copy to root storage
    if ! podman image exists "localhost/{{ image_name }}:{{ tag }}"; then
        echo "Container image not found. Building first..."
        just build
    fi
    
    echo "Copying image to root podman storage..."
    sudo podman image scp $(id -u)@localhost::localhost/{{ image_name }}:{{ tag }} root@localhost::localhost/{{ image_name }}:{{ tag }}

    mkdir -p output
    sudo rm -rf output/bootiso || true

    # Process ISO config template
    ISO_CONFIG="$(mktemp)"
    export TARGET_IMAGE="localhost/{{ image_name }}:{{ tag }}"
    envsubst < "bib-iso-config.toml" > "${ISO_CONFIG}"

    sudo podman run \
        --rm \
        -it \
        --privileged \
        --pull=newer \
        --security-opt label=type:unconfined_t \
        -v "${ISO_CONFIG}:/config.toml:ro" \
        -v "$(pwd)/output:/output" \
        -v "/var/lib/containers/storage:/var/lib/containers/storage" \
        "quay.io/centos-bootc/bootc-image-builder:latest" \
        --type iso \
        --chown "$(id -u):$(id -g)" \
        --use-librepo=True \
        --progress=verbose \
        --local \
        "localhost/{{ image_name }}:{{ tag }}"

    # Cleanup
    rm -f "${ISO_CONFIG}"
    echo "ISO installer built in output/bootiso/"
    
    # Auto-cleanup: Remove the copied image from root storage
    echo "Cleaning up root storage..."
    sudo podman rmi "localhost/{{ image_name }}:{{ tag }}" 2>/dev/null || true

# Clean all build artifacts and dangling images
clean:
    #!/usr/bin/bash
    set -euo pipefail

    # Remove output directory
    echo "Removing output directory..."
    sudo rm -rf output || true

    # Remove temporary build files
    echo "Removing temporary build files..."
    rm -f previous.manifest.json changelog.md output.env || true
    find . -name "*_build*" -type d -exec rm -rf {} + 2>/dev/null || true

    # Only clean dangling images from user storage (safe for distrobox)
    echo "Removing dangling images from user storage..."
    podman image prune -f || true

    # Aggressively clean ALL of root storage (targeting BIB artifacts, safe for rootless distrobox)
    echo "Aggressively cleaning root storage..."
    sudo podman system prune -a -f || true
    sudo podman volume prune -f || true
    
    # Clean BIB cache directories
    echo "Cleaning BIB cache directories..."
    sudo rm -rf /tmp/osbuild-* 2>/dev/null || true
    sudo rm -rf /var/tmp/osbuild-* 2>/dev/null || true

    echo "Cleanup complete!"

# Deep clean - more aggressive podman cleanup (WARNING: affects ALL images)
clean-all:
    #!/usr/bin/bash
    set -euo pipefail
    
    echo "⚠️   DANGER: Deep cleaning will affect ALL podman images including distrobox!   ⚠️"
    echo "This will:"
    echo "  - Remove ALL unused images (including distrobox base images)"
    echo "  - Clean ALL build caches"
    echo "  - Remove ALL unused volumes"
    echo ""
    echo "Press Ctrl+C to cancel..."
    
    # Visual countdown
    for i in {10..1}; do
        echo -ne "\rStarting in $i seconds... "
        sleep 1
    done
    echo -e "\rProceeding with deep clean...    "
    
    # Run normal cleanup
    echo "Running normal cleanup first..."
    just clean
    
    # Run deep cleanup
    echo "Starting aggressive cleanup..."
    
    # Remove ALL unused images (distrobox images could be lost)
    echo "Removing all unused images..."
    podman image prune -a -f || true
    
    # Clean ALL build caches
    echo "Cleaning all build caches..."
    podman builder prune -a -f || true
    
    # Clean ALL volumes (distrobox data could be lost)
    echo "Cleaning all unused volumes..."
    podman volume prune -f || true
    
    echo "Deep cleanup complete - distrobox data may have been removed!"

# Format Just files (check and auto-fix)
format:
    #!/usr/bin/bash
    set -e

    # Check and format a justfile
    format_file() {
        local file="$1"
        echo "Checking $file..."
        if ! just --unstable --fmt --check -f "$file" 2>/dev/null; then
            echo "  → Formatting $file"
            just --unstable --fmt -f "$file"
        else
            echo "  ✓ Already formatted"
        fi
    }

    # Process .just files
    find . -type f -name "*.just" | while read -r file; do
        format_file "$file"
    done

    # Process Justfile
    format_file "Justfile"

    echo "All Just files are properly formatted!"
