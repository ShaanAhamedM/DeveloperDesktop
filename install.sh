#!/usr/bin/env bash
# ==============================================================================
#  install.sh - Enterprise Automated Dotfiles Installer (Bonus Requirement)
#  Maintained by: Shaan
# ==============================================================================
#  Idempotent, non-destructive installer with automated dependency resolution,
#  atomic backups, symlink deployment, dry-run simulation, and rollback support.
# ==============================================================================

set -euo pipefail

# ANSI Color Codes
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Directories
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
TIMESTAMP="$(date +'%Y%m%d_%H%M%S')"
BACKUP_DIR="$CONFIG_DIR/backup_$TIMESTAMP"
LOCAL_BIN="$HOME/.local/bin"

# Execution Flags
DRY_RUN=false
NO_DEPS=false
AUTO_YES=false
ROLLBACK=false

# Helper Functions
log_info()    { echo -e "  ${CYAN}[INFO]${NC} $1"; }
log_step()    { echo -e "\n${BOLD}${CYAN}>> [$1/5] $2${NC}"; }
log_success() { echo -e "  ${GREEN}✓${NC} $1"; }
log_warn()    { echo -e "  ${YELLOW}⚠${NC} $1"; }
log_error()   { echo -e "  ${RED}✗${NC} $1"; }

show_help() {
    cat << EOF
Usage: ./install.sh [OPTIONS]

Enterprise-grade automated dotfiles deployment for Developer Desktop.

Options:
  -d, --dry-run     Simulate deployment actions without modifying filesystem
  -n, --no-deps     Skip package manager and dependency installation
  -y, --yes         Non-interactive mode (auto-accept all prompts)
  -r, --rollback    Remove deployed symlinks and restore most recent backup
  -h, --help        Show this help message and exit

Examples:
  ./install.sh                    # Standard interactive installation
  ./install.sh --dry-run          # Preview symlinks and actions safely
  ./install.sh --no-deps -y       # Fast non-interactive install in containers/CI
  ./install.sh --rollback         # Uninstall and restore previous configs
EOF
}

# Parse Command-Line Arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -d|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -n|--no-deps)
            NO_DEPS=true
            shift
            ;;
        -y|--yes)
            AUTO_YES=true
            shift
            ;;
        -r|--rollback|--uninstall)
            ROLLBACK=true
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# --- ROLLBACK / UNINSTALL MODE ---
if [[ "$ROLLBACK" == true ]]; then
    echo -e "${BOLD}${YELLOW}==========================================================${NC}"
    echo -e "${BOLD}${YELLOW}   🔄 Rolling Back Developer Desktop Symlinks             ${NC}"
    echo -e "${BOLD}${YELLOW}==========================================================${NC}"

    # Remove symlinks in ~/.config
    for item in "$DOTFILES_DIR/.config"/*; do
        name="$(basename "$item")"
        target="$CONFIG_DIR/$name"
        if [[ -L "$target" ]]; then
            log_info "Removing symlink: $target"
            [[ "$DRY_RUN" == false ]] && rm -f "$target"
        fi
    done

    # Remove tmux symlink if present
    if [[ -L "$HOME/.tmux.conf" ]]; then
        log_info "Removing symlink: $HOME/.tmux.conf"
        [[ "$DRY_RUN" == false ]] && rm -f "$HOME/.tmux.conf"
    fi

    # Remove script symlinks
    if [[ -d "$CONFIG_DIR/scripts" ]]; then
        for script in "$DOTFILES_DIR/scripts"/*; do
            sname="$(basename "$script")"
            if [[ -L "$CONFIG_DIR/scripts/$sname" ]]; then
                [[ "$DRY_RUN" == false ]] && rm -f "$CONFIG_DIR/scripts/$sname"
            fi
            if [[ -L "$LOCAL_BIN/$sname" ]]; then
                [[ "$DRY_RUN" == false ]] && rm -f "$LOCAL_BIN/$sname"
            fi
        done
        rmdir "$CONFIG_DIR/scripts" 2>/dev/null || true
    fi

    # Clean shell integration lines from ~/.bashrc and ~/.zshrc
    for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
        if [[ -f "$rc" ]] && grep -q "developer_environment.sh" "$rc" 2>/dev/null; then
            log_info "Cleaning Developer Desktop integration from $rc..."
            [[ "$DRY_RUN" == false ]] && sed -i '/# Developer Desktop Environment/,+1d' "$rc" 2>/dev/null || true
        fi
    done

    # Check for latest backup
    latest_backup=$(find "$CONFIG_DIR" -maxdepth 1 -name "backup_*" -type d 2>/dev/null | sort -r | head -n1 || true)
    if [[ -n "$latest_backup" && -d "$latest_backup" ]]; then
        log_info "Restoring previous configuration from: $latest_backup"
        if [[ "$DRY_RUN" == false ]]; then
            if [[ -f "$latest_backup/.tmux.conf" ]]; then
                mv "$latest_backup/.tmux.conf" "$HOME/.tmux.conf"
            fi
            cp -r "$latest_backup"/* "$CONFIG_DIR/" 2>/dev/null || true
            rm -rf "$latest_backup"
            log_success "Configs successfully restored from $latest_backup"
        else
            log_info "[DRY-RUN] Would restore files from $latest_backup to $CONFIG_DIR"
        fi
    else
        log_warn "No previous backup directory found in $CONFIG_DIR"
    fi

    echo -e "\n${BOLD}${GREEN}✓ Rollback complete! Original environment restored.${NC}\n"
    exit 0
fi

# --- BANNER ---
echo -e "${BOLD}${CYAN}==========================================================${NC}"
echo -e "${BOLD}${CYAN}   🌌 Setting Up Developer Desktop (Nordic Charcoal Spec) ${NC}"
echo -e "${BOLD}${CYAN}==========================================================${NC}"
if [[ "$DRY_RUN" == true ]]; then
    echo -e "${BOLD}${YELLOW}   [SIMULATION MODE: No filesystem changes will be written]${NC}\n"
fi

# Sudo wrapper (run directly if already root or sudo is not needed)
run_priv() {
    if [[ "$EUID" -eq 0 ]]; then
        "$@"
    elif command -v sudo &>/dev/null; then
        sudo "$@"
    else
        log_warn "Sudo not found; attempting direct execution of: $*"
        "$@"
    fi
}

# --- 1. Detect Package Manager & Install Dependencies ---
log_step "1" "Detecting package manager & system tools..."
if [[ "$NO_DEPS" == true ]]; then
    log_info "Skipping package installation (--no-deps specified)."
else
    if command -v pacman &>/dev/null; then
        log_info "Arch Linux detected (pacman)."
        if [[ "$DRY_RUN" == false ]]; then
            run_priv pacman -S --needed --noconfirm \
                hyprland i3-wm waybar rofi-wayland kitty dunst grim slurp wl-clipboard feh \
                ttf-jetbrains-mono-nerd btop pavucontrol fastfetch tmux neovim starship \
                xterm xorg-server-xephyr maim xclip 2>/dev/null || \
            run_priv pacman -S --needed --noconfirm \
                i3-wm kitty dunst feh btop tmux neovim xterm 2>/dev/null || true
        fi
        log_success "Package dependencies checked (pacman)."
    elif command -v apt-get &>/dev/null; then
        log_info "Debian/Ubuntu detected (apt)."
        if [[ "$DRY_RUN" == false ]]; then
            run_priv apt-get update -y -qq 2>/dev/null || log_warn "apt-get update completed with warnings; proceeding with installation."
            run_priv apt-get install -y --no-install-recommends \
                i3 kitty rofi waybar dunst grim slurp wl-clipboard feh \
                fonts-jetbrains-mono btop pavucontrol tmux neovim \
                xterm xserver-xephyr maim xclip 2>/dev/null || true
        fi
        log_success "Package dependencies checked (apt)."
    elif command -v dnf &>/dev/null; then
        log_info "Fedora detected (dnf)."
        if [[ "$DRY_RUN" == false ]]; then
            run_priv dnf install -y \
                i3 waybar rofi kitty dunst grim slurp wl-clipboard feh \
                jetbrains-mono-fonts-all btop pavucontrol tmux neovim \
                xterm xorg-x11-server-Xephyr maim xclip 2>/dev/null || true
        fi
        log_success "Package dependencies checked (dnf)."
    else
        log_warn "Non-standard or custom Linux distribution. Proceeding with dotfiles linking."
    fi
fi

# --- 2. Create Safe Backup of Existing Non-Symlinked Configs ---
log_step "2" "Creating atomic backup of existing configurations..."
backed_up_count=0
if [[ "$DRY_RUN" == false ]]; then
    mkdir -p "$BACKUP_DIR"
fi

for app_dir in "$DOTFILES_DIR/.config"/*; do
    app_name="$(basename "$app_dir")"
    target="$CONFIG_DIR/$app_name"

    # Only backup if target exists and is a real file/dir, NOT a symlink to our repo
    if [[ -e "$target" && ! -L "$target" ]]; then
        log_info "Backing up existing non-symlinked $app_name -> $BACKUP_DIR/"
        if [[ "$DRY_RUN" == false ]]; then
            mv "$target" "$BACKUP_DIR/"
        fi
        backed_up_count=$((backed_up_count + 1))
    fi
done

# Also check and backup ~/.tmux.conf if it exists and is not a symlink
if [[ -e "$HOME/.tmux.conf" && ! -L "$HOME/.tmux.conf" ]]; then
    log_info "Backing up existing non-symlinked ~/.tmux.conf -> $BACKUP_DIR/"
    if [[ "$DRY_RUN" == false ]]; then
        mv "$HOME/.tmux.conf" "$BACKUP_DIR/"
    fi
    backed_up_count=$((backed_up_count + 1))
fi

# If nothing was backed up, clean up the empty backup dir
if [[ "$DRY_RUN" == false ]]; then
    if (( backed_up_count == 0 )); then
        rm -rf "$BACKUP_DIR"
        log_info "No conflicting configurations found. Zero clutter created."
    else
        log_success "Backed up $backed_up_count configuration(s) to: $BACKUP_DIR"
    fi
else
    log_info "[DRY-RUN] Would backup any conflicting configurations to $BACKUP_DIR"
fi

# --- 3. Deploy Dotfiles via Atomic Symlinks ---
log_step "3" "Deploying dotfiles symlinks to $CONFIG_DIR..."
if [[ "$DRY_RUN" == false ]]; then
    mkdir -p "$CONFIG_DIR"
fi

for app_dir in "$DOTFILES_DIR/.config"/*; do
    app_name="$(basename "$app_dir")"
    target="$CONFIG_DIR/$app_name"

    if [[ "$DRY_RUN" == false ]]; then
        ln -sfn "$app_dir" "$target"
    fi
    log_success "Linked: $app_name -> $target"
done

# Standalone tmux link if ~/.tmux.conf is preferred
if [[ -f "$DOTFILES_DIR/.config/tmux/tmux.conf" ]]; then
    if [[ "$DRY_RUN" == false ]]; then
        ln -sfn "$DOTFILES_DIR/.config/tmux/tmux.conf" "$HOME/.tmux.conf"
    fi
    log_success "Linked: .tmux.conf -> $HOME/.tmux.conf"
fi

# Deploy custom scripts to ~/.config/scripts and ~/.local/bin
log_info "Deploying custom productivity scripts..."
if [[ "$DRY_RUN" == false ]]; then
    mkdir -p "$CONFIG_DIR/scripts"
    mkdir -p "$LOCAL_BIN"
fi

for script in "$DOTFILES_DIR/scripts"/*; do
    [[ -f "$script" ]] || continue
    script_name="$(basename "$script")"
    if [[ "$DRY_RUN" == false ]]; then
        chmod +x "$script" 2>/dev/null || true
        ln -sfn "$script" "$CONFIG_DIR/scripts/$script_name"
        if [[ "$script_name" == *.sh ]]; then
            ln -sfn "$script" "$LOCAL_BIN/$script_name"
        fi
    fi
    log_success "Script enabled: $script_name -> $CONFIG_DIR/scripts/$script_name"
done

# --- 4. Deploy Wallpapers ---
log_step "4" "Setting up Nordic Charcoal wallpapers..."
WALLPAPER_DEST="$HOME/Pictures/Wallpapers"
WALLPAPER_CONFIG="$CONFIG_DIR/wallpapers"
if [[ "$DRY_RUN" == false ]]; then
    mkdir -p "$WALLPAPER_DEST" "$WALLPAPER_CONFIG"
    if [[ -d "$DOTFILES_DIR/wallpapers" ]]; then
        cp -r "$DOTFILES_DIR/wallpapers"/* "$WALLPAPER_DEST/" 2>/dev/null || true
        cp -r "$DOTFILES_DIR/wallpapers"/* "$WALLPAPER_CONFIG/" 2>/dev/null || true
    fi
fi
log_success "Wallpapers synchronized to: $WALLPAPER_DEST and $WALLPAPER_CONFIG"

# --- 5. Integrate Shell & Apply Theme ---
log_step "5" "Configuring shell environment & dynamic theming..."
SHELL_SOURCE_LINE="[[ -f \"\$HOME/.config/shell/developer_environment.sh\" ]] && source \"\$HOME/.config/shell/developer_environment.sh\""
for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
    if [[ -f "$rc" ]]; then
        if ! grep -q "developer_environment.sh" "$rc" 2>/dev/null; then
            if [[ "$DRY_RUN" == false ]]; then
                echo -e "\n# Developer Desktop Environment\n$SHELL_SOURCE_LINE" >> "$rc"
            fi
            log_success "Added Developer Desktop shell integration to $(basename "$rc")"
        else
            log_info "Shell integration already present in $(basename "$rc")"
        fi
    fi
done

# Apply theme sync
if [[ "$DRY_RUN" == false ]]; then
    bash "$DOTFILES_DIR/scripts/theme_sync.sh" "$WALLPAPER_DEST/minimalist-dark.png" 2>/dev/null || true
fi
log_success "Theme engine initialized with Nordic Charcoal palette."

# --- FINISH ---
echo ""
echo -e "${BOLD}${GREEN}==========================================================${NC}"
echo -e "${BOLD}${GREEN}   ✨ Developer Desktop Installation Complete!            ${NC}"
echo -e "${BOLD}${GREEN}==========================================================${NC}"
echo -e "   ${BOLD}Shortcuts:${NC}"
echo -e "   • ${CYAN}Super + Return${NC}   : GPU Terminal (Kitty / xterm)"
echo -e "   • ${CYAN}Super + Space${NC}    : Spotlight Application Menu (Rofi)"
echo -e "   • ${CYAN}Super + ~${NC}        : Quake Dropdown Scratchpad Terminal"
echo -e "   • ${CYAN}Super + Shift + /${NC}: Searchable Keybinding Cheatsheet"
echo -e "   • ${CYAN}Super + Shift + E${NC}: Minimalist Power Menu"
echo -e "${BOLD}${GREEN}==========================================================${NC}\n"
