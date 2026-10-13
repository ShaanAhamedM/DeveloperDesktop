#!/usr/bin/env bash
# ==============================================================================
#  launch_desktop.sh - Instant Native Linux Developer Desktop via WSLg
#  Maintained by: Shaan
# ==============================================================================
#  Launches a full, isolated 1600x900 Linux developer desktop window directly
#  on your Windows desktop with zero network or Remote Desktop configuration!
# ==============================================================================

set -euo pipefail

DISPLAY_NUM=":1"
RESOLUTION="${1:-1600x900}"

echo ">> Starting Developer Desktop ($RESOLUTION) on Display $DISPLAY_NUM..."

# Clean up any previous instances and stale locks
pkill -f "Xephyr $DISPLAY_NUM" 2>/dev/null || true
rm -f "/tmp/.X${DISPLAY_NUM#:}-lock" "/tmp/.X11-unix/X${DISPLAY_NUM#:}" 2>/dev/null || true

# 1. Launch Xephyr window on Windows host via WSLg
Xephyr -br -ac -noreset -screen "$RESOLUTION" "$DISPLAY_NUM" &
XEPHYR_PID=$!

sleep 1.5

# 2. Merge X11 resources and set Wallpaper inside the desktop window
DISPLAY="$DISPLAY_NUM" xrdb -merge "$HOME/.Xresources" 2>/dev/null || true
WALLPAPER_FILE="$HOME/.config/wallpapers/minimalist-dark.png"
if [[ ! -f "$WALLPAPER_FILE" ]]; then
    WALLPAPER_FILE="$(dirname "$0")/../wallpapers/minimalist-dark.png"
fi
DISPLAY="$DISPLAY_NUM" feh --bg-fill "$WALLPAPER_FILE" 2>/dev/null || true

# 3. Launch the i3 Window Manager inside the desktop window
echo ">> Launching i3 window manager with Nordic Charcoal theme..."
DISPLAY="$DISPLAY_NUM" exec i3
