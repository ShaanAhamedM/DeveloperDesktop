#!/usr/bin/env bash
# ==============================================================================
#  power_menu.sh - Minimalist Power Menu for Developer Desktop
#  Maintained by: Shaan
# ==============================================================================

set -euo pipefail

# Options with Nerd Font Icons
lock="  Lock"
suspend="󰒲  Suspend"
logout="󰍃  Logout"
reboot="󰜉  Reboot"
shutdown="  Power Off"

options="$lock\n$suspend\n$logout\n$reboot\n$shutdown"

if ! command -v rofi &>/dev/null || [[ -z "${DISPLAY:-}" && -z "${WAYLAND_DISPLAY:-}" ]]; then
    echo "Developer Desktop Power Menu:"
    echo "1) Lock"
    echo "2) Suspend"
    echo "3) Logout"
    echo "4) Reboot"
    echo "5) Power Off"
    exit 0
fi

chosen=$(echo -e "$options" | rofi -dmenu -i -p "Power" -theme-str 'window {width: 280px; padding: 12px;} listview {lines: 5;}')

case "$chosen" in
    "$lock")
        hyprlock 2>/dev/null || swaylock 2>/dev/null || loginctl lock-session 2>/dev/null || true
        ;;
    "$suspend")
        systemctl suspend 2>/dev/null || true
        ;;
    "$logout")
        hyprctl dispatch exit 0 2>/dev/null || i3-msg exit 2>/dev/null || loginctl terminate-session "${XDG_SESSION_ID:-}" 2>/dev/null || true
        ;;
    "$reboot")
        systemctl reboot 2>/dev/null || sudo reboot
        ;;
    "$shutdown")
        systemctl poweroff 2>/dev/null || sudo poweroff
        ;;
esac
