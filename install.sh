#!/usr/bin/env bash
# ==============================================================================
#  install.sh - One-Command Automated Dotfiles Installer (Bonus Requirement)
#  Maintained by: Shaan
# ==============================================================================
#  Idempotent, non-destructive installer with automated dependency resolution,
#  backup of existing configs, and symlink deployment.
# ==============================================================================

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.config/backup_$(date +'%Y%m%d_%H%M%S')"
CONFIG_DIR="$HOME/.config"

echo "=========================================================="
echo "   🚀 Setting Up Developer Desktop (Nordic Charcoal Spec) "
echo "=========================================================="

# --- 1. Detect Package Manager & Install Dependencies ---
echo ">> [1/5] Detecting package manager..."
if command -v pacman &>/dev/null; then
    echo ">> Arch Linux detected. Installing packages via pacman..."
    sudo pacman -S --needed --noconfirm \
        hyprland i3-wm waybar rofi-wayland kitty dunst grim slurp wl-clipboard feh \
        ttf-jetbrains-mono-nerd btop pavucontrol
elif command -v apt-get &>/dev/null; then
    echo ">> Debian/Ubuntu detected. Installing packages via apt..."
    sudo apt-get update -y
    sudo apt-get install -y \
        i3 kitty rofi waybar dunst grim slurp wl-clipboard feh \
        fonts-jetbrains-mono btop pavucontrol
elif command -v dnf &>/dev/null; then
    echo ">> Fedora detected. Installing packages via dnf..."
    sudo dnf install -y \
        hyprland i3 waybar rofi kitty dunst grim slurp wl-clipboard feh \
        jetbrains-mono-fonts-all btop pavucontrol
else
    echo ">> Note: Could not detect standard package manager. Please ensure required tools are installed manually."
fi

# --- 2. Create Safe Backup of Existing Configs ---
echo ">> [2/5] Backing up existing configurations to: $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"
for app in hypr i3 kitty waybar rofi dunst; do
    if [[ -d "$CONFIG_DIR/$app" && ! -L "$CONFIG_DIR/$app" ]]; then
        echo "   Backing up existing $app..."
        mv "$CONFIG_DIR/$app" "$BACKUP_DIR/"
    fi
done

# --- 3. Deploy Dotfiles via Symlinks ---
echo ">> [3/5] Deploying dotfiles to $CONFIG_DIR..."
mkdir -p "$CONFIG_DIR"

for app_dir in "$DOTFILES_DIR/.config"/*; do
    app_name="$(basename "$app_dir")"
    target="$CONFIG_DIR/$app_name"
    echo "   Linking $app_name -> $target"
    ln -sfn "$app_dir" "$target"
done

# Deploy custom scripts to ~/.config/scripts and ~/.local/bin
mkdir -p "$CONFIG_DIR/scripts"
mkdir -p "$HOME/.local/bin"
for script in "$DOTFILES_DIR/scripts"/*; do
    chmod +x "$script"
    script_name="$(basename "$script")"
    ln -sfn "$script" "$CONFIG_DIR/scripts/$script_name"
    ln -sfn "$script" "$HOME/.local/bin/$script_name"
done

# --- 4. Deploy Wallpaper ---
echo ">> [4/5] Setting up wallpapers..."
mkdir -p "$HOME/Pictures/Wallpapers"
cp -r "$DOTFILES_DIR/wallpapers"/* "$HOME/Pictures/Wallpapers/" 2>/dev/null || true

# --- 5. Finish and Apply Theme ---
echo ">> [5/5] Initializing dynamic theme engine..."
bash "$DOTFILES_DIR/scripts/theme_sync.sh" "$HOME/Pictures/Wallpapers/minimalist-dark.png" 2>/dev/null || true

echo ""
echo "=========================================================="
echo "   ✨ Installation Complete! Your Developer Desktop is ready."
echo "   Press Super + Return for Terminal"
echo "   Press Super + Space for App Menu"
echo "   Press Super + ~ for Dropdown Scratchpad"
echo "=========================================================="
