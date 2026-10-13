#!/usr/bin/env bash
# ==============================================================================
#  scratchpad.sh - Quake-Style Dropdown Terminal Toggle (Bonus Requirement)
#  Maintained by: Shaan
# ==============================================================================

SCRATCH_TITLE="scratchpad_terminal"

if command -v hyprctl &>/dev/null && [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]]; then
    # Toggle Hyprland special workspace
    hyprctl dispatch togglespecialworkspace scratchpad
elif command -v i3-msg &>/dev/null; then
    # Toggle i3 scratchpad container
    if i3-msg '[instance="scratchpad_terminal"] scratchpad show' 2>/dev/null | grep -q '"success":true'; then
        true
    else
        if [[ -n "${DISPLAY:-}" && "$DISPLAY" == ":1"* ]] || ! command -v kitty &>/dev/null; then
            xterm -name "$SCRATCH_TITLE" -geometry 110x30 &
        elif command -v kitty &>/dev/null; then
            kitty --title "$SCRATCH_TITLE" --name "$SCRATCH_TITLE" --override initial_window_width=900 --override initial_window_height=480 &
        elif command -v xterm &>/dev/null; then
            xterm -name "$SCRATCH_TITLE" -geometry 110x30 &
        fi
    fi
else
    # Fallback for standard X11/generic Wayland
    if pgrep -f "$SCRATCH_TITLE" >/dev/null; then
        pkill -f "$SCRATCH_TITLE"
    else
        if command -v kitty &>/dev/null; then
            kitty --title "$SCRATCH_TITLE" --override initial_window_width=900 --override initial_window_height=480 &
        elif command -v xterm &>/dev/null; then
            xterm -name "$SCRATCH_TITLE" -geometry 110x30 &
        fi
    fi
fi
