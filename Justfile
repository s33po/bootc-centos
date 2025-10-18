export repo_owner := env("GITHUB_REPOSITORY_OWNER", "s33po")
export image_name := env("IMAGE_NAME", "bootc-centos")
export major_version := env("MAJOR_VERSION", "10")
export default_tag := env("DEFAULT_TAG", "latest")
export bib_image := env("BIB_IMAGE", "quay.io/centos-bootc/bootc-image-builder:latest")

[private]
default:
    @just --list

# Check Just Syntax
[group('Just')]
check:
    #!/usr/bin/bash
    find . -type f -name "*.just" | while read -r file; do
    	echo "Checking syntax: $file"
    	just --unstable --fmt --check -f $file
    done
    echo "Checking syntax: Justfile"
    just --unstable --fmt --check -f Justfile

# Fix Just Syntax
[group('Just')]
fix:
    #!/usr/bin/bash
    find . -type f -name "*.just" | while read -r file; do
    	echo "Checking syntax: $file"
    	just --unstable --fmt -f $file
    done
    echo "Checking syntax: Justfile"
    just --unstable --fmt -f Justfile || { exit 1; }

# Clean Repo
[group('Utility')]
clean:
    #!/usr/bin/bash
    set -eoux pipefail
    touch _build
    find *_build* -exec rm -rf {} \;
    rm -f previous.manifest.json
    rm -f changelog.md
    rm -f output.env

# Sudo Clean Repo
[group('Utility')]
[private]
sudo-clean:
    just sudoif just clean

# sudoif bash function
[group('Utility')]
[private]
sudoif command *args:
    #!/usr/bin/bash
    function sudoif(){
        if [[ "${UID}" -eq 0 ]]; then
            "$@"
        elif [[ "$(command -v sudo)" && -n "${SSH_ASKPASS:-}" ]] && [[ -n "${DISPLAY:-}" || -n "${WAYLAND_DISPLAY:-}" ]]; then
            /usr/bin/sudo --askpass "$@" || exit 1
        elif [[ "$(command -v sudo)" ]]; then
            /usr/bin/sudo "$@" || exit 1
        else
            exit 1
        fi
    }
    sudoif {{ command }} {{ args }}

build $target_image=image_name $tag=default_tag:
    #!/usr/bin/env bash

    # Get Version
    ver="${tag}-${major_version}.$(date +%Y%m%d)"

    BUILD_ARGS=()
    BUILD_ARGS+=("--build-arg" "MAJOR_VERSION=${major_version}")
    BUILD_ARGS+=("--build-arg" "IMAGE_NAME=${image_name}")
    BUILD_ARGS+=("--build-arg" "IMAGE_VENDOR=${repo_owner}")
    if [[ -z "$(git status -s)" ]]; then
        BUILD_ARGS+=("--build-arg" "SHA_HEAD_SHORT=$(git rev-parse --short HEAD)")
    fi

    podman build \
        "${BUILD_ARGS[@]}" \
        --pull=newer \
        --tag "${image_name}:${tag}" \
        .

_rootful_load_image $target_image=image_name $tag=default_tag:
    #!/usr/bin/bash
    set -eoux pipefail

    if [[ -n "${SUDO_USER:-}" || "${UID}" -eq "0" ]]; then
        echo "Already root or running under sudo, no need to load image from user podman."
        exit 0
    fi

    set +e
    resolved_tag=$(podman inspect -t image "${target_image}:${tag}" | jq -r '.[].RepoTags.[0]')
    return_code=$?
    set -e

    if [[ $return_code -eq 0 ]]; then
        # Load into Rootful Podman
        ID=$(just sudoif podman images --filter reference="${target_image}:${tag}" --format "'{{ '{{.ID}}' }}'")
        if [[ -z "$ID" ]]; then
            COPYTMP=$(mktemp -p "${PWD}" -d -t _build_podman_scp.XXXXXXXXXX)
            just sudoif TMPDIR=${COPYTMP} podman image scp ${UID}@localhost::"${target_image}:${tag}" root@localhost::"${target_image}:${tag}"
            rm -rf "${COPYTMP}"
        fi
    else
        # Make sure the image is present and/or up to date
        just sudoif podman pull "${target_image}:${tag}"
    fi

_build-bib $target_image $tag $type $config: (_rootful_load_image target_image tag)
    #!/usr/bin/env bash
    set -euo pipefail

    mkdir -p "output"

    echo "Cleaning up previous build"
    if [[ $type == iso ]]; then
      sudo rm -rf "output/bootiso" || true
    else
      sudo rm -rf "output/${type}" || true
    fi

    args="--type ${type} --progress=verbose"

    if [[ $target_image == localhost/* ]]; then
      args+=" --local"
    fi

    # Add librepo flag for ISO builds
    if [[ $type == iso ]]; then
      args+=" --use-librepo=True"
    fi

    # Handle template processing for ISO builds
    if [[ $type == iso ]]; then
      ISO_CONFIG="$(mktemp)"
      export TARGET_IMAGE="${target_image}:${tag}"
      envsubst < "${config}" > "${ISO_CONFIG}"
      config_mount="${ISO_CONFIG}:/config.toml:ro"
    else
      config_mount="$(pwd)/${config}:/config.toml:ro"
    fi

    sudo podman run \
      --rm \
      -it \
      --privileged \
      --pull=newer \
      --net=host \
      --security-opt label=type:unconfined_t \
      -v "${config_mount}" \
      -v $(pwd)/output:/output \
      -v /var/lib/containers/storage:/var/lib/containers/storage \
      "${bib_image}" \
      ${args} \
      "${target_image}"

    # Clean up temporary ISO config if created
    if [[ $type == iso && -n "${ISO_CONFIG:-}" ]]; then
      rm -f "${ISO_CONFIG}"
    fi

    sudo chown -R $USER:$USER output

_rebuild-bib $target_image $tag $type $config: (build target_image tag) && (_build-bib target_image tag type config)

[group('Build VM Image')]
build-vm $target_image=("localhost/" + image_name) $tag=default_tag: && (_build-bib target_image tag "qcow2" "bib-config.toml")

[group('Build VM Image')]
rebuild-vm $target_image=("localhost/" + image_name) $tag=default_tag: && (_rebuild-bib target_image tag "qcow2" "bib-config.toml")

[group('Build Installer')]
build-iso $target_image=("ghcr.io/" + repo_owner + "/" + image_name) $tag=default_tag: && (_build-bib target_image tag "iso" "bib-iso-config.toml")

[group('Build Installer')]
rebuild-iso $target_image=("ghcr.io/" + repo_owner + "/" + image_name) $tag=default_tag: && (_rebuild-bib target_image tag "iso" "bib-iso-config.toml")
