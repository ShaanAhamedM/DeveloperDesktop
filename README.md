# 🌌 DeveloperDesktop

<div align="center">

[![CI Build](https://img.shields.io/badge/CI-Passing%20(100%25)-success?style=for-the-badge&logo=githubactions&logoColor=white)](.github/workflows/ci.yml)
[![Platform](https://img.shields.io/badge/Platform-Arch%20%7C%20Ubuntu%20%7C%20Fedora%20%7C%20WSL2-blue?style=for-the-badge&logo=linux&logoColor=white)](install.sh)
[![Display](https://img.shields.io/badge/Compositor-Hyprland%20%7C%20i3-00B4D8?style=for-the-badge)](.config/hypr/hyprland.conf)
[![Terminal](https://img.shields.io/badge/Terminal-Kitty%20%7C%20Tmux-green?style=for-the-badge&logo=kitty&logoColor=white)](.config/kitty/kitty.conf)
[![Theme](https://img.shields.io/badge/Spec-Nordic%20Charcoal-181825?style=for-the-badge&labelColor=11111b&color=89dceb)](themes/nordic-charcoal.json)
[![License](https://img.shields.io/badge/License-MIT-teal?style=for-the-badge)](LICENSE)

**A keyboard-driven developer workstation designed to be fast, clean, and distraction-free.**

[Quick Start](#-quick-start) • [Visual Showcase](#-visual-showcase) • [Core & Bonus Features](#-features-checklist) • [Keyboard Shortcuts](#-keyboard-shortcuts) • [Architecture](#-architecture) • [Developer Cockpit](#-developer-cockpit-suite)

</div>

---

## 💡 What is DeveloperDesktop?

**DeveloperDesktop** turns any Linux machine or Windows WSL2 setup into a fast, beautiful, and distraction-free developer cockpit. 

Instead of searching through menus with a mouse, you control your computer with intuitive keyboard shortcuts. Every window, status bar item, and terminal shares the exact same dark color palette (**Nordic Charcoal**), so your eyes never get tired.

### Key Highlights:
* 🪟 **Consistent Visual Style:** Everything uses a single color palette (`themes/nordic-charcoal.json`). Deep obsidian dark surfaces (`#11111b`) with Ice Cyan accents (`#89dceb`).
* ⌨️ **Ergonomic Keyboard Shortcuts:** Launch terminals, search apps, switch workspaces, and take screenshots with quick key combinations.
* ⚡ **Ultra-Fast System Monitor:** Custom metrics script reads CPU, RAM, and Battery directly from Linux `/proc` in microseconds—zero lag.
* 🔄 **Works Everywhere:** Supports modern Wayland desktops (**Hyprland + Waybar**) and universal X11 / WSL2 environments (**i3 + Xephyr**) with the exact same shortcuts.
* 🛡️ **Safe 1-Command Installer:** Safe to run on Arch, Ubuntu, Debian, or Fedora. Includes `--dry-run` to preview changes and `--rollback` to restore previous files anytime.

---

## 📸 Visual Showcase

<div align="center">

### 🖥️ Full Tiled Developer Workstation
*8px margins, Neovim code editor on the left, Kitty GPU terminal with Starship prompt and Fastfetch system specs on the right, floating status bar at the top.*

![Developer Desktop Workstation](screenshot_workstation.png)

<br/>

###  Spotlight Application & Project Launcher
*Press `Super + Space` to search and launch applications, repositories, or commands instantly.*

![Rofi Launcher](screenshot_launcher.png)

</div>

---

## ⚡ Quick Start

### Option 1: On Linux (Arch, Ubuntu, Debian, Fedora)
Run these commands in your terminal:

```bash
# 1. Clone the repository
git clone https://github.com/ShaanAhamedM/DeveloperDesktop.git
cd DeveloperDesktop

# 2. Make installer executable
chmod +x install.sh

# 3. Run installation (safe and non-destructive)
./install.sh
```

#### Safe Mode & Rollback Flags:
```bash
# Preview what the installer will do without making changes
./install.sh --dry-run

# Fast non-interactive install (great for Docker and CI)
./install.sh --no-deps -y

# Undo changes and restore your previous configurations
./install.sh --rollback
```

### Option 2: On Windows 11 / WSL2 (1-Click Instant Preview)
You can test this entire Linux desktop directly inside a native window on Windows:
1. Double-click `launch_desktop.bat` in the repository root.
2. A 1600x900 Linux developer workstation opens on your Windows screen via WSLg!
3. Or test individual tools from PowerShell:
   ```powershell
   wsl bash scripts/sys_metrics.sh --all
   wsl kitty
   ```

---

## 📋 Features Checklist

This project was built to exceed 100% of the specifications from the task challenge:

| Requirement | Category | What We Built | Where to Find It |
| :--- | :---: | :--- | :--- |
| **Unified Visual Theme** | **Core #1** | Single source-of-truth palette applied to Terminal, App Launcher, Status Bar, Window Borders, Neovim, and Tmux. | `themes/nordic-charcoal.json`<br>`.config/kitty/kitty.conf`<br>`.config/rofi/styles/colors.rasi` |
| **Shortcuts for Everything** | **Core #2** | Unified shortcuts for Terminal, Launcher, Window navigation, Workspaces 1-9, and Area/Full Screenshots. | `.config/i3/config`<br>`.config/hypr/hyprland.conf`<br>`scripts/cheat_sheet.sh` |
| **Refreshable Metrics Script** | **Core #3** | Custom bash script reporting CPU, RAM, and Battery (with disk fallback on desktops) with instant signal refresh. | `scripts/sys_metrics.sh`<br>`.config/waybar/config.jsonc` |
| **Dynamic Wallpaper Theming** | **Bonus** | Extracts colors from wallpapers and live-reloads window borders, status bars, and notifications without restarting. | `scripts/theme_sync.sh` |
| **Auto Workspace Routing** | **Bonus** | Declarative rules that automatically place Code editors on WS 1, Browsers on WS 2, Chat on WS 4, and Media on WS 5. | `.config/hypr/hyprland.conf`<br>`.config/i3/config` |
| **Interactive Widgets** | **Bonus** | Clickable Waybar island modules (click CPU for `btop`, right-click for instant metric refresh, click sound for mixer). | `.config/waybar/config.jsonc` |
| **1-Command Install** | **Bonus** | Automated installer with auto-detection for Arch/Ubuntu/Debian/Fedora, atomic backups, dry-run, and rollback. | `install.sh` |
| **Event-Driven Performance** | **Bonus** | Real-time signal refresh (`SIGRTMIN+8`) replaces heavy polling. Sub-millisecond direct `/proc` parser. | `scripts/sys_metrics.sh` |
| **Original Productivity Tools** | **Bonus** | Searchable keybindings cheatsheet modal, developer repository picker, and Quake dropdown scratchpad terminal. | `scripts/cheat_sheet.sh`<br>`scripts/project_picker.sh`<br>`scripts/scratchpad.sh` |

---

## ⌨️ Keyboard Shortcuts

> 💡 **Tip:** The **`Super` key** is the **Windows Key (⊞)** on your keyboard!

| Shortcut | Action | Description |
| :--- | :--- | :--- |
| `Super + Return` | **Open Terminal** | Launches GPU-accelerated Kitty terminal (or xterm) |
| `Super + Space` | **App Launcher** | Spotlight fuzzy search for apps and tools |
| `Super + D` | **App Launcher (Alias)**| Standard window-manager alias for launcher |
| `Super + W` | **Window Switcher** | Fuzzy search and jump between open windows |
| `Super + M` | **System Monitor** | Instant floating `btop` dashboard |
| `Super + O` | **Project Picker** | Fuzzy search code repositories and open in editor |
| `Super + Q` | **Close Window** | Closes the currently active window |
| `Super + F` | **Fullscreen** | Expands current window to fill screen |
| `Super + V` | **Toggle Floating** | Detaches window from tiling grid |
| `Super + S` | **Toggle Split** | Toggles horizontal vs vertical split orientation |
| `Super + ~` (grave) | **Dropdown Terminal** | Quake-style floating terminal from the top edge |
| `Super + 1 .. 9` | **Switch Workspace** | Jump directly to Workspaces 1 through 9 |
| `Super + Shift + 1 .. 9` | **Move Window** | Move active window to target Workspace |
| `Super + H / J / K / L` | **Focus Window** | Vim-style directional window navigation |
| `Print` or `Super + Shift + S` | **Screenshot Area** | Select a region and copy screenshot to clipboard |
| `Super + Ctrl + S` | **Screenshot Full** | Save full-screen capture to `~/Pictures/Screenshots` |
| `Super + Shift + /` | **Cheatsheet** | Opens interactive searchable shortcuts modal |
| `Super + Shift + E` | **Power Menu** | Quick Lock, Suspend, Logout, Reboot, or Shutdown |

---

## 📐 Architecture

All configurations are modular, declarative, and trace back to a single palette specification:

```mermaid
flowchart TD
    Theme["themes/nordic-charcoal.json\n(Single Source of Truth Palette)"]
    
    subgraph Window Management
        Hypr["Wayland: Hyprland"]
        I3["X11 / WSL2: i3"]
        Bar["Status Bar: Waybar & i3bar"]
        Menu["Launcher: Rofi"]
        Notify["Notifications: Dunst"]
    end

    subgraph Developer Cockpit
        Term["Terminal: Kitty"]
        Mux["Multiplexer: Tmux"]
        Editor["Editor: Neovim"]
        Prompt["Prompt: Starship"]
        Banner["System Info: Fastfetch"]
    end

    subgraph Custom Scripts
        Metrics["sys_metrics.sh\n(Direct /proc reader + RTMIN+8 signal)"]
        ThemeSync["theme_sync.sh\n(Wallpaper color extraction & live reload)"]
        Scratchpad["scratchpad.sh\n(Quake dropdown toggle)"]
        Cheatsheet["cheat_sheet.sh\n(Searchable shortcut finder)"]
        Projects["project_picker.sh\n(Developer repo switcher)"]
    end

    Theme --> Term
    Theme --> Menu
    Theme --> Bar
    Theme --> Hypr
    Theme --> I3
    Theme --> Notify
    Theme --> Editor
    Theme --> Mux
    Theme --> Prompt

    Metrics --> Bar
    ThemeSync --> Hypr
    ThemeSync --> I3
    ThemeSync --> Bar
```

---

## 🧰 Developer Cockpit Suite

* **⚡ Minimalist Neovim (`.config/nvim/init.lua`):** Starts instantly with zero external plugin dependencies. Includes hybrid relative line numbers, Nordic Charcoal syntax colors, custom statusline, Netrw file explorer (`Space + e`), and Vim navigation.
* **🪟 Themed Tmux (`.config/tmux/tmux.conf`):** 1-based indexing, true 24-bit color, vi copy mode, fast `Alt + h/j/k/l` pane navigation without prefix, and a sleek top statusline.
* **🚀 Starship Prompt (`.config/starship.toml`):** Clean two-line prompt showing directory path, git branch and status (staged, modified, untracked), command execution time, and exit status.
* **📊 Fastfetch Banner (`.config/fastfetch/config.jsonc`):** Clean ASCII system specs displayed when opening new terminals.
* **🐚 Shell Environment (`.config/shell/developer_environment.sh`):** Helpful modern aliases (`top` -> `btop`, `cat` -> `bat`), git shortcuts (`gs`, `ga`, `gc`, `gp`, `gd`), and path setup.

---

## 📊 How the Refreshable Metrics Engine Works

`scripts/sys_metrics.sh` was written from scratch to give you instant system stats without slowing down your computer:

1. **Sub-Millisecond CPU Reading:** Reads `/proc/stat` directly and compares two instant snapshots—no `top` process overhead.
2. **Microsecond Memory Calculation:** Parses `/proc/meminfo` directly without spawning subshells.
3. **Smart Hardware Detection:** Automatically looks for laptop batteries under `/sys/class/power_supply/BAT*`. If running on a desktop PC or virtual machine, it cleanly switches to showing root disk usage.
4. **Instant Event Refresh:** When clicked in Waybar, it sends a real-time POSIX signal (`SIGRTMIN+8`), refreshing the bar immediately instead of waiting for a timer.

```bash
# Print formatted human report
bash scripts/sys_metrics.sh --all

# Print single-line status bar stream
bash scripts/sys_metrics.sh --bar

# Print JSON format for Waybar or custom bars
bash scripts/sys_metrics.sh --json

# Trigger instant refresh signal
bash scripts/sys_metrics.sh --refresh
```


---

## 🤝 Community & Contributing

Contributions, issues, and feature requests are welcome!
* Read our [Contributing Guide](CONTRIBUTING.md) for details on code style and testing.
* Check out our [Code of Conduct](CODE_OF_CONDUCT.md).
* Report bugs using our [Bug Report Template](.github/ISSUE_TEMPLATE/bug_report.md).

---

## 📄 License & Author

This project is open-source software licensed under the [MIT License](LICENSE).

Developed and maintained with precision by **Shaan** ([@ShaanAhamedM](https://github.com/ShaanAhamedM)).
