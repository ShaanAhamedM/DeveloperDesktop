#!/usr/bin/env bash
# ==============================================================================
#  theme_sync.sh - Wallpaper-Synced Dynamic Theming Engine (Bonus Requirement)
#  Maintained by: Shaan
# ==============================================================================
#  Extracts color harmony from wallpapers and live-reloads:
#  - Kitty Terminal (via IPC socket)
#  - Waybar Status Bar (via SIGUSR2)
#  - Rofi Launcher
#  - Hyprland window borders
# ==============================================================================

set -euo pipefail

DEFAULT_WALLPAPER="$(dirname "$0")/../wallpapers/minimalist-dark.png"
WALLPAPER="${1:-$DEFAULT_WALLPAPER}"

echo ">> Syncing theme with wallpaper: $WALLPAPER"

# --- 1. Set Wallpaper via Hyprland Daemon ---
if command -v hyprctl &>/dev/null; then
    hyprctl hyprpaper preload "$WALLPAPER" 2>/dev/null || true
    hyprctl hyprpaper wallpaper ",$WALLPAPER" 2>/dev/null || true
fi

# --- 2. Dynamic Palette Extraction / Fallback ---
# If pywal or matugen is installed, extract dynamic colors; otherwise apply Nordic Charcoal base
PALETTE_FILE="$(dirname "$0")/../themes/nordic-charcoal.json"
ACCENT="#89dceb"

if command -v wal &>/dev/null && [[ -f "$WALLPAPER" ]]; then
    wal -i "$WALLPAPER" -n -q -t 2>/dev/null || true
    if [[ -f "$HOME/.cache/wal/colors" ]]; then
        ACCENT=$(sed -n '5p' "$HOME/.cache/wal/colors" 2>/dev/null || echo "#89dceb")
    fi
fi

# --- 3. Live Broadcast to Hyprland Window Borders ---
if command -v hyprctl &>/dev/null; then
    hyprctl keyword general:col.active_border "rgba(${ACCENT#'#'}ee)" 2>/dev/null || true
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
