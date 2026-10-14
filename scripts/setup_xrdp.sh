#!/usr/bin/env bash
# ==============================================================================
#  setup_xrdp.sh - Automated Remote Desktop (RDP) Configurator for WSL & Linux
# ==============================================================================
#  Configures XRDP on port 3390 to prevent port collisions with Windows Host RDP.
#  Dynamically identifies target user, deploys session configs, and restarts service.
# ==============================================================================

set -euo pipefail

TARGET_USER="${SUDO_USER:-$(id -u -n)}"
TARGET_HOME="$(getent passwd "$TARGET_USER" 2>/dev/null | cut -d: -f6 || true)"
TARGET_HOME="${TARGET_HOME:-$HOME}"
TARGET_GROUP="$(id -g -n "$TARGET_USER" 2>/dev/null || echo "$TARGET_USER")"
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo ">> Configuring XRDP on port 3390 for user '$TARGET_USER' (Home: $TARGET_HOME)..."

# 1. Update xrdp.ini to port 3390 to prevent collision with Windows host RDP
if [[ -f /etc/xrdp/xrdp.ini ]]; then
    sed -i 's/^port=3389/port=3390/g' /etc/xrdp/xrdp.ini 2>/dev/null || true
fi

# 2. Configure user session to start i3
cat << 'EOF' > "$TARGET_HOME/.xsession"
#!/bin/sh
export DESKTOP_SESSION=i3
export XDG_CURRENT_DESKTOP=i3
exec i3
EOF
chmod +x "$TARGET_HOME/.xsession"
chown "$TARGET_USER:$TARGET_GROUP" "$TARGET_HOME/.xsession" 2>/dev/null || true

# 3. Deploy dotfiles to user home
mkdir -p "$TARGET_HOME/.config"
if [[ -d "$DOTFILES_DIR/.config" ]]; then
    cp -r "$DOTFILES_DIR/.config"/* "$TARGET_HOME/.config/" 2>/dev/null || true
fi
mkdir -p "$TARGET_HOME/.config/scripts"
if [[ -d "$DOTFILES_DIR/scripts" ]]; then
    cp -r "$DOTFILES_DIR/scripts"/* "$TARGET_HOME/.config/scripts/" 2>/dev/null || true
    chmod +x "$TARGET_HOME/.config/scripts"/*.sh 2>/dev/null || true
fi
mkdir -p "$TARGET_HOME/.config/wallpapers"
mkdir -p "$TARGET_HOME/Pictures/Wallpapers"
if [[ -d "$DOTFILES_DIR/wallpapers" ]]; then
    cp -r "$DOTFILES_DIR/wallpapers"/* "$TARGET_HOME/.config/wallpapers/" 2>/dev/null || true
    cp -r "$DOTFILES_DIR/wallpapers"/* "$TARGET_HOME/Pictures/Wallpapers/" 2>/dev/null || true
fi

chown -R "$TARGET_USER:$TARGET_GROUP" "$TARGET_HOME/.config" 2>/dev/null || true
chown -R "$TARGET_USER:$TARGET_GROUP" "$TARGET_HOME/Pictures" 2>/dev/null || true

# 4. Restart XRDP Service if available
if command -v systemctl &>/dev/null && systemctl is-active --quiet xrdp 2>/dev/null; then
    systemctl restart xrdp 2>/dev/null || true
elif command -v service &>/dev/null; then
    service xrdp restart 2>/dev/null || true
fi

echo ">> XRDP configured on port 3390 successfully for user '$TARGET_USER'!"
