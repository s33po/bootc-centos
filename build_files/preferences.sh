#!/usr/bin/env bash

set -xeuo pipefail

echo "::group::📝 SYSTEM PREFERENCES"

# Disable lastlog display
authselect enable-feature with-silent-lastlog

# Configure bootc updates
sed -i 's|^ExecStart=.*|ExecStart=/usr/bin/bootc update --quiet|' /usr/lib/systemd/system/bootc-fetch-apply-updates.service
sed -i 's|^OnUnitInactiveSec=.*|OnUnitInactiveSec=7d\nPersistent=true|' /usr/lib/systemd/system/bootc-fetch-apply-updates.timer
sed -i 's|#AutomaticUpdatePolicy.*|AutomaticUpdatePolicy=stage|' /etc/rpm-ostreed.conf
sed -i 's|#LockLayering.*|LockLayering=true|' /etc/rpm-ostreed.conf

# Set up dconf system profile
mkdir -p /etc/dconf/profile
cat <<EOF > /etc/dconf/profile/user
user-db:user
system-db:local
EOF

# Set GNOME system-wide defaults
mkdir -p /etc/dconf/db/local.d
cat <<EOF > /etc/dconf/db/local.d/00-gnome
[org/gnome/desktop/interface]
color-scheme='prefer-dark'
gtk-theme='Adwaita'
font-name='Adwaita Sans 11'
document-font-name='Adwaita Sans 11'
monospace-font-name='JetBrains Mono 12'
icon-theme='Adwaita'
cursor-theme='Adwaita'
accent-color='blue'
clock-format='24h'
clock-show-weekday=true

[org/gnome/desktop/wm/preferences]
button-layout='appmenu:minimize,maximize,close'
center-new-windows=true

[org/gnome/desktop/peripherals/mouse]
accel-profile='flat'

[org/gnome/shell]
enable-hot-corners=false

[org/gnome/settings-daemon/plugins/media-keys/custom-keybindings]
custom-keybindings=['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/']

[org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0]
name='Launch Ptyxis'
binding='<Super>Return'
command='/usr/bin/ptyxis --new-window'

[org/gnome/nautilus/preferences]
sort-directories-first=true
default-folder-viewer='list-view'

[org/gnome/desktop/calendar]
show-weekdate=true
EOF

# Mitigate cursor lag with VRR and make GNOME slightly faster(?)
cat <<EOF >> /etc/environment
MUTTER_DEBUG_FORCE_KMS_MODE=simple
GNOME_SHELL_SLOWDOWN_FACTOR=0.8
EOF

# Apply dconf settings 
dconf update

# Write firewalld zone "Workstation" (more permissive than stock)
mkdir -p /usr/lib/firewalld/zones
cat > /usr/lib/firewalld/zones/Workstation.xml <<EOF
<?xml version="1.0" encoding="utf-8"?>
<zone>
  <short>Workstation</short>
  <description>Unsolicited incoming network packets are rejected from port 1 to 1024,
except for select network services. Incoming packets that are related to
outgoing network connections are accepted. Outgoing network connections are
allowed.</description>
  <service name="dhcpv6-client"/>
  <service name="ssh"/>
  <service name="samba-client"/>
  <service name="dns"/>
  <port protocol="udp" port="1025-65535"/>
  <port protocol="tcp" port="1025-65535"/>
  <forward/>
</zone>
EOF

# Set default firewalld zone to "Workstation"
firewall-offline-cmd --set-default-zone=Workstation

# Set zsh as default shell for new users
sed -i 's/bash/zsh/g' /etc/default/useradd

# Set default zsh config
mkdir -p /etc/skel
cat > /etc/skel/.zshrc << 'EOF'
# Completion system
autoload -Uz compinit promptinit up-line-or-beginning-search down-line-or-beginning-search
promptinit
compinit

# History search widgets
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

# Key bindings for better history navigation
bindkey '^[[A' up-line-or-beginning-search    # Up arrow
bindkey '^[[B' down-line-or-beginning-search  # Down arrow
bindkey '^P' up-line-or-beginning-search      # Ctrl+P
bindkey '^N' down-line-or-beginning-search    # Ctrl+N

# Completion settings
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' completer _expand _complete _ignored _approximate

# Prompt with colors
PROMPT='%F{green}%n%f@%F{magenta}%m%f %F{blue}%B%~%b%f %# '

# History settings
HISTFILE=~/.zsh_history
HISTSIZE=99999
SAVEHIST=$HISTSIZE
setopt EXTENDED_HISTORY          # Save timestamp and duration
setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicates first
setopt HIST_IGNORE_DUPS          # Ignore consecutive duplicates
setopt HIST_IGNORE_SPACE         # Ignore commands starting with space
setopt HIST_VERIFY               # Show command before executing from history
setopt INC_APPEND_HISTORY        # Append immediately
setopt SHARE_HISTORY             # Share history between sessions

# Shell options
setopt AUTO_CD                   # cd by typing directory name
setopt AUTO_PUSHD                # Push directories to stack
setopt PUSHD_IGNORE_DUPS         # Don't push duplicates
setopt CORRECT                   # Try to correct commands
setopt CORRECT_ALL               # Try to correct all arguments
setopt INTERACTIVE_COMMENTS      # Allow comments in interactive shell
setopt NO_BEEP                   # Don't beep on errors

# Aliases
alias ls='ls --color=auto'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'
alias diff='diff --color=auto'
alias myip='curl ifconfig.me'
alias fixperms='sudo chown -R $USER:$USER'
alias please='sudo $(history | tail -1 | sed "s/^[[:space:]]*[0-9]*[[:space:]]*//")'
alias defpaks='xargs -a /etc/flatpak/defpaks.list -r flatpak install -y --noninteractive flathub && echo "Flatpak installation complete!"'
EOF

echo "::endgroup::"