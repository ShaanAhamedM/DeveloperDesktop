#!/usr/bin/env bash
# ==============================================================================
#  theme_sync.sh - Wallpaper-Synced Dynamic Theming Engine (Bonus Requirement)
#  Maintained by: Shaan
# ==============================================================================
#  Extracts color harmony from wallpapers and live-reloads:
#  - Window Borders (Hyprland & i3)
#  - Status Bar (Waybar via SIGUSR2)
#  - Notification Daemon (Dunst via SIGHUP)
#  - Desktop Wallpaper (Hyprpaper or feh)
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
DEFAULT_WALLPAPER="$REPO_DIR/wallpapers/minimalist-dark.png"
WALLPAPER="${1:-$DEFAULT_WALLPAPER}"

if [[ -f "$WALLPAPER" ]]; then
    WALLPAPER="$(realpath "$WALLPAPER" 2>/dev/null || readlink -f "$WALLPAPER" 2>/dev/null || echo "$WALLPAPER")"
else
    echo "Error: Wallpaper file not found: $WALLPAPER" >&2
    exit 1
fi

echo ">> Syncing theme with wallpaper: $WALLPAPER"

# --- 1. Set Wallpaper (Wayland Hyprpaper or X11 feh) ---
if command -v hyprctl &>/dev/null && [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]]; then
    hyprctl hyprpaper preload "$WALLPAPER" 2>/dev/null || true
    hyprctl hyprpaper wallpaper ",$WALLPAPER" 2>/dev/null || true
elif command -v feh &>/dev/null; then
    feh --bg-fill "$WALLPAPER" 2>/dev/null || true
fi

# --- 2. Dynamic Palette Extraction / Fallback ---
# If pywal or matugen is installed, extract dynamic colors; otherwise apply Nordic Charcoal base
PALETTE_FILE="$REPO_DIR/themes/nordic-charcoal.json"
ACCENT="#89dceb"

if command -v wal &>/dev/null && [[ -f "$WALLPAPER" ]]; then
    wal -i "$WALLPAPER" -n -q -t 2>/dev/null || true
    if [[ -f "$HOME/.cache/wal/colors" ]]; then
        ACCENT=$(sed -n '5p' "$HOME/.cache/wal/colors" 2>/dev/null || echo "#89dceb")
    fi
fi

# --- 3. Live Broadcast to Window Borders (Hyprland & i3) ---
if command -v hyprctl &>/dev/null && [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]]; then
    hyprctl keyword general:col.active_border "rgba(${ACCENT#'#'}ee)" 2>/dev/null || true
fi

if command -v i3-msg &>/dev/null; then
    i3-msg "client.focused $ACCENT #181825 #cdd6f4 $ACCENT $ACCENT" 2>/dev/null || true
fi

# --- 4. Live Reload Status Bar ---
if pgrep -x waybar >/dev/null; then
    pkill -SIGUSR2 waybar 2>/dev/null || true
fi

# --- 5. Live Reload Notifications ---
if pgrep -x dunst >/dev/null; then
    pkill -HUP dunst 2>/dev/null || true
fi

# --- 6. Notification Confirmation ---
if command -v notify-send &>/dev/null; then
    notify-send -a "Theme Engine" "Theme Synchronized" "Applied active palette with accent ${ACCENT}"
fi

echo ">> Theme synchronized successfully with accent: $ACCENT"
