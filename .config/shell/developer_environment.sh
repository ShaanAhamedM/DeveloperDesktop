# ==============================================================================
#  developer_environment.sh - Universal Shell Environment & Aliases
#  Maintained by: Shaan
# ==============================================================================

# Starship Prompt Initialization
if command -v starship &>/dev/null; then
    eval "$(starship init bash 2>/dev/null || true)"
fi

# Modern CLI Tool Replacements
if command -v btop &>/dev/null; then
    alias top='btop'
    alias htop='btop'
fi

if command -v bat &>/dev/null; then
    alias cat='bat --theme="Nord"'
elif command -v batcat &>/dev/null; then
    alias cat='batcat --theme="Nord"'
fi

# Standard Developer Aliases
alias ll='ls -lah --color=auto --group-directories-first'
alias la='ls -A --color=auto'
alias l='ls -CF --color=auto'
alias grep='grep --color=auto'
alias diff='diff --color=auto'

# DeveloperDesktop Helpers
alias desktop-metrics='$HOME/.config/scripts/sys_metrics.sh --all'
alias desktop-sync-theme='$HOME/.config/scripts/theme_sync.sh'
alias desktop-projects='$HOME/.config/scripts/project_picker.sh'
alias desktop-keys='$HOME/.config/scripts/cheat_sheet.sh --text'
alias desktop-scratch='$HOME/.config/scripts/scratchpad.sh'

# Git Productivity Shortcuts
alias gs='git status -sb'
alias ga='git add'
alias gc='git commit -m'
alias gp='git push'
alias gl='git log --oneline --graph --decorate -n 15'
alias gd='git diff'

# Editor Fallback
if command -v nvim &>/dev/null; then
    export EDITOR="nvim"
    export VISUAL="nvim"
    alias vim='nvim'
    alias vi='nvim'
elif command -v vim &>/dev/null; then
    export EDITOR="vim"
    export VISUAL="vim"
fi

# Add custom scripts and local bin to PATH
if [[ -d "$HOME/.local/bin" && ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    export PATH="$HOME/.local/bin:$PATH"
fi
if [[ -d "$HOME/.config/scripts" && ":$PATH:" != *":$HOME/.config/scripts:"* ]]; then
    export PATH="$HOME/.config/scripts:$PATH"
fi
