#!/usr/bin/env bash
# ==============================================================================
#  scratchpad.sh - Quake-Style Dropdown Terminal Toggle (Bonus Requirement)
#  Maintained by: Shaan
# ==============================================================================

SCRATCH_TITLE="scratchpad_terminal"

if command -v hyprctl &>/dev/null; then
    # Toggle Hyprland special workspace
    hyprctl dispatch togglespecialworkspace scratchpad
else
    # Fallback for standard X11/generic Wayland: spawn or focus floating kitty
    if pgrep -f "$SCRATCH_TITLE" >/dev/null; then
        pkill -f "$SCRATCH_TITLE"
    else
        kitty --title "$SCRATCH_TITLE" --override initial_window_width=900 --override initial_window_height=480 &
    fi
fi
