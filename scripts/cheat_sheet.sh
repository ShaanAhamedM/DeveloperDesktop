#!/usr/bin/env bash
# ==============================================================================
#  cheat_sheet.sh - Interactive Searchable Keybinding Cheatsheet
#  Maintained by: Shaan
# ==============================================================================

CHEATSHEET="
Super + Return        󰞷 Launch Terminal (Kitty)
Super + Space          Launch Application Menu (Rofi)
Super + W              Switch Open Windows
Super + Q             󰅖 Close Focused Window
Super + F             󰊓 Toggle Fullscreen
Super + V             󰉍 Toggle Floating Mode
Super + P             󰕰 Toggle Pseudo-Tiling
Super + ~              Quake Dropdown Scratchpad Terminal
Super + 1..9          󰄲 Jump to Workspace 1 through 9
Super + Shift + 1..9  󰚡 Move Window to Workspace 1..9
Super + H/J/K/L       󰁌 Move Focus (Vim Directional)
Print / Super+Shift+S  Screenshot Area (Clipboard)
Super + Ctrl + S       Screenshot Fullscreen (Save)
Super + Shift + /      Open this Keybinding Cheatsheet
"

if [[ -n "${DISPLAY:-}" || -n "${WAYLAND_DISPLAY:-}" ]] && command -v rofi &>/dev/null; then
    echo -e "$CHEATSHEET" | sed '/^$/d' | rofi -dmenu -i -p "Shortcuts" \
        -theme-str 'window {width: 620px; padding: 16px;} listview {lines: 10;}'
else
    echo "=========================================================="
    echo "  Developer Desktop - Keyboard Shortcuts Reference        "
    echo "=========================================================="
    echo -e "$CHEATSHEET" | sed '/^$/d'
    echo "=========================================================="
fi
