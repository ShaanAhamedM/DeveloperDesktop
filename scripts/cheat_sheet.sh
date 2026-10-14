#!/usr/bin/env bash
# ==============================================================================
#  cheat_sheet.sh - Interactive Searchable Keybinding Cheatsheet
#  Maintained by: Shaan
# ==============================================================================

CHEATSHEET="
Super + Return        󰞷 Launch Terminal (Kitty / xterm)
Super + Space / D      Launch Application Menu (Rofi)
Super + W              Switch Open Windows
Super + M             󰍛 Open System Monitor (btop)
Super + O / P         󱉯 Developer Project Picker
Super + Q             󰅖 Close Focused Window
Super + F             󰊓 Toggle Fullscreen
Super + V             󰉍 Toggle Floating Mode
Super + S             󰕰 Toggle Tiling Split
Super + ~ (grave)      Quake Dropdown Scratchpad Terminal
Super + 1..9          󰄲 Jump to Workspace 1 through 9
Super + Shift + 1..9  󰚡 Move Window to Workspace 1..9
Super + H/J/K/L       󰁌 Move Focus (Vim Directional)
Print / Super+Shift+S  Screenshot Area (Clipboard)
Super + Ctrl + S       Screenshot Fullscreen (Save)
Super + Shift + /      Open this Keybinding Cheatsheet
Super + Shift + E      Minimalist Power Menu
"

if [[ "${1:-}" == "--text" || "${1:-}" == "-t" || "${1:-}" == "--help" || "${1:-}" == "-h" ]] || ! command -v rofi &>/dev/null || [[ -z "${DISPLAY:-}" && -z "${WAYLAND_DISPLAY:-}" ]]; then
    echo "=========================================================="
    echo "  Developer Desktop - Keyboard Shortcuts Reference        "
    echo "=========================================================="
    echo -e "$CHEATSHEET" | sed '/^$/d'
    echo "=========================================================="
else
    echo -e "$CHEATSHEET" | sed '/^$/d' | rofi -dmenu -i -p "Shortcuts" \
        -theme-str 'window {width: 650px; padding: 16px;} listview {lines: 12;}'
fi
