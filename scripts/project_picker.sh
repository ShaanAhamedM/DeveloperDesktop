#!/usr/bin/env bash
# ==============================================================================
#  project_picker.sh - Developer Project Switcher (Bonus Requirement)
#  Maintained by: Shaan
# ==============================================================================

set -euo pipefail

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

# Clean project list: prune .git, node_modules, build caches, and hidden directories
get_projects() {
    find "${VALID_DIRS[@]}" -maxdepth 2 -mindepth 1 -type d \
        -not -path '*/.*' \
        -not -path '*/node_modules*' \
        -not -path '*/venv*' \
        -not -path '*/target*' \
        -not -path '*/dist*' \
        -not -path '*/build*' 2>/dev/null || true
}

if [[ "${1:-}" == "--text" || "${1:-}" == "-t" || "${1:-}" == "--help" || "${1:-}" == "-h" ]] || ! command -v rofi &>/dev/null || [[ -z "${DISPLAY:-}" && -z "${WAYLAND_DISPLAY:-}" ]]; then
    echo "=========================================="
    echo "  Developer Desktop - Detected Projects   "
    echo "=========================================="
    get_projects | head -n 20
    echo "=========================================="
    exit 0
fi

selected=$(get_projects | rofi -dmenu -i -p "Project" -theme-str 'window {width: 650px;}')

if [[ -n "$selected" ]]; then
    # Open in Code if installed
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
