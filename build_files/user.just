# Justfile for system maintenance and configuration

[private]
default:
    @just --list

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

# Update distroboxes and toolboxes
[group('System')]
update-containers:
    #!/usr/bin/env bash
    echo "=== Updating Distroboxes and Toolboxes ==="

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

    # Update toolboxes
    if command -v toolbox &> /dev/null; then
        echo "Updating Toolboxes..."
        toolbox_list=$(toolbox list --containers 2>/dev/null | tail -n +2 | awk '{print $2}' | grep -v "^$" || echo "")
        if [[ -n "$toolbox_list" ]]; then
            echo "$toolbox_list" | while read -r container; do
                echo "Updating toolbox: $container"
                toolbox run --container "$container" sudo dnf update -y
            done
        else
            echo "No toolboxes found"
        fi
    fi

    echo "Container updates completed!"

# Clean up system caches and unused packages
[group('System')]
cleanup-system:
    #!/usr/bin/env bash
    echo "Cleaning up system..."

    # Clean flatpak cache
    if command -v flatpak &> /dev/null; then
        echo "Cleaning Flatpak cache..."
        flatpak uninstall --unused -y
    fi

    # Clean brew cache
    if command -v brew &> /dev/null; then
        echo "Cleaning Homebrew cache..."
        brew cleanup
    fi

    # Clean podman images and containers
    if command -v podman &> /dev/null; then
        echo "Cleaning Podman containers and images..."
        podman system prune -f
        podman image prune -f
        podman volume prune -f
    fi

    # Clean user cache
    echo "Cleaning user cache directories..."
    rm -rf ~/.cache/thumbnails/*

    # Clean logs
    echo "Cleaning old journal logs..."
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

# Install and configure Homebrew/Linuxbrew
[group('Homebrew')]
setup-brew:
    #!/usr/bin/env bash
    echo "Setting up Homebrew/Linuxbrew..."

    if command -v brew &> /dev/null; then
        echo "Homebrew is already installed!"
        brew --version
        echo "To configure auto-updates, run: just setup-brew-autoupdate"
        exit 0
    fi

    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add to shell profile and configure completions
    echo "Configuring shell environment..."
    if [[ -f ~/.zshrc ]]; then
        if ! grep -q 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' ~/.zshrc; then
            echo '' >> ~/.zshrc
            echo '# Homebrew integration' >> ~/.zshrc
            echo 'if command -v brew &> /dev/null; then' >> ~/.zshrc
            echo '  eval "$(brew shellenv)"' >> ~/.zshrc
            echo '  # Add completions for systemwide Homebrew' >> ~/.zshrc
            echo '  if [ -d /home/linuxbrew/.linuxbrew/share/zsh/site-functions ]; then' >> ~/.zshrc
            echo '    fpath=(/home/linuxbrew/.linuxbrew/share/zsh/site-functions $fpath)' >> ~/.zshrc
            echo '  fi' >> ~/.zshrc
            echo '  # Add completions for user-local Homebrew' >> ~/.zshrc
            echo '  if [ -d "$HOME/.linuxbrew/share/zsh/site-functions" ]; then' >> ~/.zshrc
            echo '    fpath=($HOME/.linuxbrew/share/zsh/site-functions $fpath)' >> ~/.zshrc
            echo '  fi' >> ~/.zshrc
            echo 'fi' >> ~/.zshrc
        fi
    fi

    if [[ -f ~/.bashrc ]]; then
        if ! grep -q 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' ~/.bashrc; then
            echo '' >> ~/.bashrc
            echo '# Homebrew integration' >> ~/.bashrc
            echo 'if command -v brew &> /dev/null; then' >> ~/.bashrc
            echo '  eval "$(brew shellenv)"' >> ~/.bashrc
            echo 'fi' >> ~/.bashrc
        fi
    fi

    # Source it for current session
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

    echo "Homebrew installation completed!"
    echo "Please restart your shell or run: source ~/.zshrc (or ~/.bashrc)"
    echo "To setup auto-updates, run: just setup-brew-autoupdate"

# Enable automatic weekly Homebrew updates
[group('Homebrew')]
setup-brew-autoupdate:
    #!/usr/bin/env bash
    if ! command -v brew &> /dev/null; then
        echo "Homebrew is not installed. Run 'just setup-brew' first."
        exit 1
    fi

    echo "Setting up Homebrew auto-updates..."

    # Create systemd user service directory
    mkdir -p ~/.config/systemd/user

    # Create the service file
    {
        echo "[Unit]"
        echo "Description=Update Homebrew packages"
        echo "After=network-online.target"
        echo "Wants=network-online.target"
        echo ""
        echo "[Service]"
        echo "Type=oneshot"
        echo "ExecStart=/bin/bash -c 'eval \"\$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)\" && brew update && brew upgrade && brew cleanup'"
        echo "User=%i"
        echo "Group=%i"
        echo ""
        echo "[Install]"
        echo "WantedBy=default.target"
    } > ~/.config/systemd/user/homebrew-update.service

    # Create the timer file for weekly updates
    {
        echo "[Unit]"
        echo "Description=Update Homebrew packages weekly"
        echo "Requires=homebrew-update.service"
        echo ""
        echo "[Timer]"
        echo "OnCalendar=weekly"
        echo "Persistent=true"
        echo "RandomizedDelaySec=2h"
        echo ""
        echo "[Install]"
        echo "WantedBy=timers.target"
    } > ~/.config/systemd/user/homebrew-update.timer

    # Reload systemd and enable the timer
    systemctl --user daemon-reload
    systemctl --user enable homebrew-update.timer
    systemctl --user start homebrew-update.timer

    echo "Homebrew auto-updates configured!"
    echo "Updates will run weekly. Check status with: systemctl --user status homebrew-update.timer"

# Show Homebrew installation and auto-update status
[group('Homebrew')]
brew-status:
    #!/usr/bin/env bash
    if ! command -v brew &> /dev/null; then
        echo "Homebrew is not installed. Run 'just setup-brew' to install it."
        exit 1
    fi

    echo "=== Homebrew Status ==="
    echo "Version: $(brew --version | head -n1)"
    echo "Prefix: $(brew --prefix)"
    echo ""
    echo "=== Auto-update Status ==="
    if systemctl --user is-enabled homebrew-update.timer &>/dev/null; then
        echo "Auto-updates: enabled (weekly)"
        echo "Timer status: $(systemctl --user is-active homebrew-update.timer)"
        echo "Last run: $(systemctl --user show homebrew-update.service --property=ExecMainStartTimestamp --value)"
        echo "Next run: $(systemctl --user show homebrew-update.timer --property=NextElapseUSecRealtime --value | xargs -I {} date -d @{} 2>/dev/null || echo 'Unknown')"
    else
        echo "Auto-updates: disabled"
        echo "Run 'just setup-brew-autoupdate' to enable"
    fi

# Update Homebrew packages manually
[group('Homebrew')]
update-brew:
    #!/usr/bin/env bash
    if ! command -v brew &> /dev/null; then
        echo "Homebrew is not installed. Run 'just setup-brew' to install it."
        exit 1
    fi

    echo "Updating Homebrew..."
    brew update && brew upgrade && brew cleanup
    echo "Homebrew update completed!"

# Install full Fonts group to user directory for comprehensive font coverage
[group('System')]
install-fonts:
    #!/usr/bin/env bash
    set -euo pipefail
    sudo bootc usr-overlay
    
    echo "Installing fonts..."  
    sudo dnf -y group install "Fonts"

    echo "Copying fonts to ~/.local/share/fonts..."
    mkdir -p ~/.local/share/fonts
    cp -rv /usr/share/fonts/* ~/.local/share/fonts/

    echo "Updating font cache..."
    fc-cache -fv ~/.local/share/fonts
    echo ""
    echo "Fonts installed to user directory!"
    echo "To see installed fonts: fc-list"

# Show this help message
[group('Help')]
help:
    @just --list