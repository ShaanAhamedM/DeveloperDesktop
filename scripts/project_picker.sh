#!/usr/bin/env bash
# ==============================================================================
#  project_picker.sh - Developer Project Switcher (Bonus Requirement)
#  Maintained by: Shaan
# ==============================================================================

SEARCH_DIRS=("$HOME/Projects" "$HOME/Code" "$HOME/Developer" "$HOME/workspace")
VALID_DIRS=()

for dir in "${SEARCH_DIRS[@]}"; do
    if [[ -d "$dir" ]]; then
        VALID_DIRS+=("$dir")
    fi
done

if (( ${#VALID_DIRS[@]} == 0 )); then
    mkdir -p "$HOME/Projects"
    VALID_DIRS=("$HOME/Projects")
fi

selected=$(find "${VALID_DIRS[@]}" -maxdepth 2 -mindepth 1 -type d 2>/dev/null | rofi -dmenu -i -p "Project" -theme-str 'window {width: 650px;}')

if [[ -n "$selected" ]]; then
    # Open in VS Code and open terminal
    code "$selected" 2>/dev/null || true
    kitty --directory "$selected" &
fi
