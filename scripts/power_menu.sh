#!/usr/bin/env bash
# ==============================================================================
#  power_menu.sh - Minimalist Power Menu for Developer Desktop
#  Maintained by: Shaan
# ==============================================================================

# Options
lock="  Lock"
suspend="󰒲  Suspend"
logout="󰍃  Logout"
reboot="󰜉  Reboot"
shutdown="  Power Off"

options="$lock\n$suspend\n$logout\n$reboot\n$shutdown"

chosen=$(echo -e "$options" | rofi -dmenu -p "Power" -theme-str 'window {width: 280px; padding: 12px;} listview {lines: 5;}')

case "$chosen" in
    "$lock")
        hyprlock 2>/dev/null || swaylock 2>/dev/null || loginctl lock-session
        ;;
    "$suspend")
        systemctl suspend
        ;;
    "$logout")
        hyprctl dispatch exit 0 2>/dev/null || pkill -KILL -u "$USER"
        ;;
    "$reboot")
        systemctl reboot
        ;;
    "$shutdown")
        systemctl poweroff
        ;;
esac
