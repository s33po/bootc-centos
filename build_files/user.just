# Justfile for system maintenance and configuration

[private]
default:
    @jmain --list

# Update (system, flatpaks, brew)
[group('System')]
update:
    #!/usr/bin/env bash
    echo "=== Updating system ==="

    # Update system
    echo "Updating system..."
    sudo bootc upgrade

    # Update flatpaks
    echo "Updating Flatpaks..."
    flatpak update -y

    # Update homebrew
    if command -v brew &> /dev/null; then
        echo "Updating Homebrew..."
        brew update && brew upgrade && brew cleanup
    fi

    echo "All updates completed!"

# Update distrobox containers
[group('System')]
update-dbox:
    #!/usr/bin/env bash
    echo "=== Updating Distroboxes ==="

    # Update distroboxes
    if command -v distrobox &> /dev/null; then
        echo "Updating Distroboxes..."
        distrobox_list=$(distrobox list --no-color 2>/dev/null | tail -n +2 | awk '{print $3}' | grep -v "^$" || echo "")
        if [[ -n "$distrobox_list" ]]; then
            echo "$distrobox_list" | while read -r container; do
                echo "Updating distrobox: $container"
                distrobox upgrade "$container"
            done
        else
            echo "No distroboxes found"
        fi
    fi

    echo "Distroboxes updated!"

# Clean up system
[group('System')]
clean-system:
    #!/usr/bin/env bash

    # Clean flatpak
    if command -v flatpak &> /dev/null; then
        echo "Cleaning Flatpak.."
        flatpak uninstall --unused -y
    fi

    # Clean brew
    if command -v brew &> /dev/null; then
        echo "Cleaning Homebrew..."
        brew cleanup
    fi

    # Clean podman
    if command -v podman &> /dev/null; then
        echo "Cleaning Podman..."
        podman system prune -f
        podman image prune -f
        podman volume prune -f
    fi

    # Clean logs
    echo "Cleaning logs..."
    sudo journalctl --vacuum-time=7d

    echo "System cleanup completed!"

# Install default Flatpaks
[group('Flatpak')]
install-flatpaks:
    #!/usr/bin/env bash
    echo "Setting up Flatpak and installing default applications..."

    # Ensure Flathub is available
    if ! flatpak remotes | grep -q flathub; then
        echo "Adding Flathub repository..."
        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    fi

    # Install default flatpaks
    if [[ ! -f /etc/flatpak/defpaks.list ]]; then
        echo "Error: Default flatpaks list not found at /etc/flatpak/defpaks.list"
        exit 1
    fi

    echo "Installing packages from /etc/flatpak/defpaks.list..."
    xargs -a /etc/flatpak/defpaks.list -r flatpak install -y --noninteractive flathub
    echo "Flatpak installation complete!"

# Install gaming Flatpaks
[group('Flatpak')]
install-gaming-flatpaks:
    #!/usr/bin/env bash
    echo "Setting up Flatpak and installing gaming applications..."

    # Ensure Flathub is available
    if ! flatpak remotes | grep -q flathub; then
        echo "Adding Flathub repository..."
        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    fi

    # Install gaming flatpaks
    if [[ ! -f /etc/flatpak/gaming.list ]]; then
        echo "Error: Gaming flatpaks list not found at /etc/flatpak/gaming.list"
        exit 1
    fi

    echo "Installing packages from /etc/flatpak/gaming.list..."
    xargs -a /etc/flatpak/gaming.list -r flatpak install -y --noninteractive flathub
    echo "Gaming Flatpak installation complete!"

# Update Homebrew packages manually
[group('Homebrew')]
update-brew:
    #!/usr/bin/env bash
    if ! command -v brew &> /dev/null; then
        echo "Homebrew is not installed."
        exit 1
    fi

    echo "Updating Homebrew..."
    brew update && brew upgrade && brew cleanup
    echo "Homebrew update completed!"
