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
    # Open in Code / Neovim
    if command -v code &>/dev/null; then
        code "$selected" 2>/dev/null || true
    fi
    
    # Launch terminal in project directory
    if command -v kitty &>/dev/null; then
        kitty --directory "$selected" &
    elif command -v xterm &>/dev/null; then
        (cd "$selected" && xterm &)
    fi
fi
