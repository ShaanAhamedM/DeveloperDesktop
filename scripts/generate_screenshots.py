#!/usr/bin/env python3
"""
Screenshot Generator for Developer Desktop Showcase
Generates crisp, high-resolution (1920x1080) mockups representing the
Nordic Charcoal Developer Cockpit (Workstation & Rofi Spotlight Launcher).
"""

import os
from PIL import Image, ImageDraw, ImageFont

BG_SURFACE = "#11111b"
BG_PANEL = "#181825"
BG_ACTIVE = "#1e1e2e"
BORDER_ACCENT = "#89dceb"
BORDER_SUBTLE = "#313244"
TEXT_FG = "#cdd6f4"
TEXT_MUTED = "#6c7086"
TEXT_DARK = "#11111b"
ACCENT_CYAN = "#89dceb"
ACCENT_GREEN = "#a6e3a1"
ACCENT_YELLOW = "#f9e2af"
ACCENT_RED = "#f38ba8"
ACCENT_PURPLE = "#cba6f7"
ACCENT_BLUE = "#89b4fa"
ACCENT_ORANGE = "#fab387"

def get_font(size, bold=False):
    # Try Windows font locations, then fallback
    candidates = [
        "C:/Windows/Fonts/CascadiaCode.ttf",
        "C:/Windows/Fonts/CascadiaMono.ttf",
        "C:/Windows/Fonts/consola.ttf" if not bold else "C:/Windows/Fonts/consolab.ttf",
        "C:/Windows/Fonts/segoeui.ttf" if not bold else "C:/Windows/Fonts/segoeuib.ttf",
        "C:/Windows/Fonts/arial.ttf" if not bold else "C:/Windows/Fonts/arialbd.ttf",
    ]
    for c in candidates:
        if os.path.exists(c):
            try:
                return ImageFont.truetype(c, size)
            except Exception:
                pass
    return ImageFont.load_default()

def draw_rounded_rect(draw, bbox, radius, fill=None, outline=None, width=1):
    draw.rounded_rectangle(bbox, radius=radius, fill=fill, outline=outline, width=width)

def generate_workstation_screenshot(output_path):
    width, height = 1920, 1080
    im = Image.new("RGBA", (width, height), BG_SURFACE)
    draw = ImageDraw.Draw(im)

    font_xs = get_font(12)
    font_sm = get_font(14)
    font_base = get_font(16)
    font_bold = get_font(16, bold=True)
    font_code = get_font(15)
    font_code_bold = get_font(15, bold=True)
    font_lg = get_font(20, bold=True)

    # 1. Background subtle geometric grid dots
    for x in range(20, width, 40):
        for y in range(20, height, 40):
            draw.point((x, y), fill="#1e1e2e")

    # 2. Top Status Bar (Floating Island Bar)
    bar_y = 10
    bar_h = 38
    draw_rounded_rect(draw, (12, bar_y, width - 12, bar_y + bar_h), radius=8, fill=BG_PANEL, outline=BORDER_SUBTLE, width=1)

    # Workspaces
    ws_x = 20
    ws_y = bar_y + 6
    # WS 1 Active
    draw_rounded_rect(draw, (ws_x, ws_y, ws_x + 28, ws_y + 26), radius=5, fill=ACCENT_CYAN)
    draw.text((ws_x + 9, ws_y + 5), "1", font=font_bold, fill=TEXT_DARK)

    # WS 2..5
    for i, num in enumerate(["2", "3", "4", "5"], start=1):
        x = ws_x + (i * 34)
        draw.text((x + 8, ws_y + 5), num, font=font_base, fill=TEXT_MUTED)

    # Separator
    draw.text((ws_x + 180, ws_y + 4), "|", font=font_base, fill=BORDER_SUBTLE)

    # Active Window Title
    draw.text((ws_x + 200, ws_y + 5), "Neovim - sys_metrics.sh [Nordic Charcoal]", font=font_sm, fill=TEXT_FG)

    # Center Clock Pill
    clock_str = "14:30:15  Thu 15 Oct"
    clock_w = 180
    clock_x = (width - clock_w) // 2
    draw_rounded_rect(draw, (clock_x, ws_y, clock_x + clock_w, ws_y + 26), radius=6, fill=BG_ACTIVE, outline=BORDER_SUBTLE)
    draw.text((clock_x + 18, ws_y + 5), clock_str, font=font_sm, fill=ACCENT_CYAN)

    # Right Metric Pills
    r_x = width - 24
    
    # Power Button
    r_x -= 30
    draw_rounded_rect(draw, (r_x, ws_y, r_x + 26, ws_y + 26), radius=5, fill="#313244")
    draw.text((r_x + 8, ws_y + 4), "X", font=font_bold, fill=ACCENT_RED)

    # Wifi
    r_x -= 105
    draw_rounded_rect(draw, (r_x, ws_y, r_x + 95, ws_y + 26), radius=5, fill=BG_ACTIVE, outline=BORDER_SUBTLE)
    draw.text((r_x + 12, ws_y + 5), "Eth Connected", font=font_xs, fill=ACCENT_GREEN)

    # Battery
    r_x -= 120
    draw_rounded_rect(draw, (r_x, ws_y, r_x + 110, ws_y + 26), radius=5, fill=BG_ACTIVE, outline=BORDER_SUBTLE)
    draw.text((r_x + 10, ws_y + 5), "BAT 98% [Full]", font=font_xs, fill=ACCENT_CYAN)

    # RAM
    r_x -= 150
    draw_rounded_rect(draw, (r_x, ws_y, r_x + 140, ws_y + 26), radius=5, fill=BG_ACTIVE, outline=BORDER_SUBTLE)
    draw.text((r_x + 10, ws_y + 5), "RAM 3.2G/16G (20%)", font=font_xs, fill=ACCENT_PURPLE)

    # CPU
    r_x -= 90
    draw_rounded_rect(draw, (r_x, ws_y, r_x + 80, ws_y + 26), radius=5, fill=BG_ACTIVE, outline=ACCENT_CYAN, width=1)
    draw.text((r_x + 12, ws_y + 5), "CPU 12%", font=font_xs, fill=ACCENT_CYAN)

    # 3. Main Workspace Area: 2 Tiled Windows with 8px Grid Margins
    margin = 12
    gap = 10
    top_offset = bar_y + bar_h + 10
    win_w = (width - (margin * 2) - gap) // 2
    win_h = height - top_offset - margin

    # ================= LEFT WINDOW: NEOVIM =================
    left_x1 = margin
    left_y1 = top_offset
    left_x2 = left_x1 + win_w
    left_y2 = left_y1 + win_h

    # Window Container
    draw_rounded_rect(draw, (left_x1, left_y1, left_x2, left_y2), radius=8, fill=BG_SURFACE, outline=BORDER_ACCENT, width=1)

    # Title Bar
    title_h = 32
    draw_rounded_rect(draw, (left_x1, left_y1, left_x2, left_y1 + title_h), radius=8, fill=BG_PANEL)
    draw.rectangle((left_x1, left_y1 + 16, left_x2, left_y1 + title_h), fill=BG_PANEL) # square bottom corners
    draw.line((left_x1, left_y1 + title_h, left_x2, left_y1 + title_h), fill=BORDER_SUBTLE, width=1)

    # Window controls
    draw.ellipse((left_x1 + 12, left_y1 + 10, left_x1 + 24, left_y1 + 22), fill="#f38ba8")
    draw.ellipse((left_x1 + 30, left_y1 + 10, left_x1 + 42, left_y1 + 22), fill="#f9e2af")
    draw.ellipse((left_x1 + 48, left_y1 + 10, left_x1 + 60, left_y1 + 22), fill="#a6e3a1")

    # Title text
    draw.text((left_x1 + 75, left_y1 + 7), "neovim - scripts/sys_metrics.sh (Nordic Charcoal Syntax)", font=font_sm, fill=TEXT_MUTED)

    # Neovim Code Content
    code_lines = [
        (1, [("#6c7086", "#!/usr/bin/env bash")]),
        (2, [("#6c7086", "# ==============================================================================")]),
        (3, [("#6c7086", "#  sys_metrics.sh - Refreshable Modular System Performance Monitor")]),
        (4, [("#6c7086", "#  Maintained by: Shaan")]),
        (5, [("#6c7086", "# ==============================================================================")]),
        (6, [("#cba6f7", "set "), ("#cdd6f4", "-o pipefail")]),
        (7, []),
        (8, [("#89dceb", "get_cpu"), ("#cdd6f4", "() {")]),
        (9, [("#6c7086", "    # Parse /proc/stat directly for sub-millisecond execution")]),
        (10, [("#cba6f7", "    if "), ("#cdd6f4", "[[ -f /proc/stat ]]; "), ("#cba6f7", "then")]),
        (11, [("#89b4fa", "        read "), ("#cdd6f4", "-r cpu user nice system idle iowait irq softirq steal _ < /proc/stat")]),
        (12, [("#fab387", "        prev_idle"), ("#cdd6f4", "=$((idle + iowait))")]),
        (13, [("#fab387", "        prev_total"), ("#cdd6f4", "=$((user + nice + system + idle + iowait + irq + softirq + steal))")]),
        (14, [("#89b4fa", "        sleep "), ("#fab387", "0.2")]),
        (15, [("#89b4fa", "        read "), ("#cdd6f4", "-r cpu user nice system idle iowait irq softirq steal _ < /proc/stat")]),
        (16, [("#fab387", "        curr_idle"), ("#cdd6f4", "=$((idle + iowait))")]),
        (17, [("#fab387", "        curr_total"), ("#cdd6f4", "=$((user + nice + system + idle + iowait + irq + softirq + steal))")]),
        (18, [("#fab387", "        diff_idle"), ("#cdd6f4", "=$((curr_idle - prev_idle))")]),
        (19, [("#fab387", "        diff_total"), ("#cdd6f4", "=$((curr_total - prev_total))")]),
        (20, [("#cba6f7", "        if "), ("#cdd6f4", "(( diff_total > 0 )); "), ("#cba6f7", "then")]),
        (21, [("#fab387", "            cpu_usage"), ("#cdd6f4", "=$(( (1000 * (diff_total - diff_idle) / diff_total + 5) / 10 ))")]),
        (22, [("#cba6f7", "        fi")]),
        (23, [("#cba6f7", "    fi")]),
        (24, [("#89b4fa", "    echo "), ("#a6e3a1", "\"$cpu_usage\"")]),
        (25, [("#cdd6f4", "}")]),
        (26, []),
        (27, [("#89dceb", "get_ram"), ("#cdd6f4", "() {")]),
        (28, [("#6c7086", "    # Direct /proc/meminfo parsing with zero subshell lag")]),
        (29, [("#fab387", "    mem_total"), ("#cdd6f4", "=$(awk '/MemTotal/ {print $2}' /proc/meminfo || echo 1)")]),
        (30, [("#fab387", "    mem_available"), ("#cdd6f4", "=$(awk '/MemAvailable/ {print $2}' /proc/meminfo)")]),
        (31, [("#fab387", "    mem_used"), ("#cdd6f4", "=$((mem_total - mem_available))")]),
        (32, [("#89b4fa", "    echo "), ("#a6e3a1", "\"$(( 100 * mem_used / mem_total ))\"")]),
        (33, [("#cdd6f4", "}")]),
    ]

    cy = left_y1 + title_h + 12
    line_h = 24
    for lnum, spans in code_lines:
        # Cursorline highlight on line 21
        if lnum == 21:
            draw.rectangle((left_x1 + 1, cy - 2, left_x2 - 1, cy + line_h - 2), fill=BG_PANEL)
            # Active Line Number
            draw.text((left_x1 + 14, cy), f"{lnum:2d}", font=font_code_bold, fill=ACCENT_CYAN)
        else:
            # Line Number
            draw.text((left_x1 + 14, cy), f"{lnum:2d}", font=font_code, fill="#45475a")

        cx = left_x1 + 54
        for col, text in spans:
            draw.text((cx, cy), text, font=font_code, fill=col)
            # approximate width
            cx += int(len(text) * 9.2)

        cy += line_h

    # Neovim Statusline
    nvim_status_y = left_y2 - 28
    draw.rectangle((left_x1, nvim_status_y, left_x2, left_y2), fill=BG_PANEL)
    draw.line((left_x1, nvim_status_y, left_x2, nvim_status_y), fill=BORDER_SUBTLE, width=1)
    
    # Mode Pill
    draw_rounded_rect(draw, (left_x1 + 6, nvim_status_y + 4, left_x1 + 80, nvim_status_y + 24), radius=4, fill=ACCENT_CYAN)
    draw.text((left_x1 + 16, nvim_status_y + 5), "NORMAL", font=font_bold, fill=TEXT_DARK)

    draw.text((left_x1 + 92, nvim_status_y + 5), "sys_metrics.sh [bash]  utf-8  unix", font=font_sm, fill=TEXT_FG)
    draw.text((left_x2 - 160, nvim_status_y + 5), "21:13  |  10%  |  204L", font=font_sm, fill=TEXT_MUTED)

    # ================= RIGHT WINDOW: KITTY TERMINAL + TMUX =================
    right_x1 = left_x2 + gap
    right_y1 = top_offset
    right_x2 = right_x1 + win_w
    right_y2 = right_y1 + win_h

    # Container
    draw_rounded_rect(draw, (right_x1, right_y1, right_x2, right_y2), radius=8, fill=BG_SURFACE, outline=BORDER_SUBTLE, width=1)

    # Title Bar
    draw_rounded_rect(draw, (right_x1, right_y1, right_x2, right_y1 + title_h), radius=8, fill=BG_PANEL)
    draw.rectangle((right_x1, right_y1 + 16, right_x2, right_y1 + title_h), fill=BG_PANEL)
    draw.line((right_x1, right_y1 + title_h, right_x2, right_y1 + title_h), fill=BORDER_SUBTLE, width=1)

    # Controls
    draw.ellipse((right_x1 + 12, right_y1 + 10, right_x1 + 24, right_y1 + 22), fill="#f38ba8")
    draw.ellipse((right_x1 + 30, right_y1 + 10, right_x1 + 42, right_y1 + 22), fill="#f9e2af")
    draw.ellipse((right_x1 + 48, right_y1 + 10, right_x1 + 60, right_y1 + 22), fill="#a6e3a1")

    # Title text
    draw.text((right_x1 + 75, right_y1 + 7), "kitty - tmux [session: cockpit]", font=font_sm, fill=TEXT_MUTED)

    # Tmux Top Status Bar
    tmux_y = right_y1 + title_h
    tmux_h = 26
    draw.rectangle((right_x1, tmux_y, right_x2, tmux_y + tmux_h), fill="#181825")
    draw.line((right_x1, tmux_y + tmux_h, right_x2, tmux_y + tmux_h), fill=BORDER_SUBTLE, width=1)

    # Tmux Active Window
    draw_rounded_rect(draw, (right_x1 + 4, tmux_y + 3, right_x1 + 120, tmux_y + 23), radius=4, fill=ACCENT_CYAN)
    draw.text((right_x1 + 12, tmux_y + 5), "1:verification*", font=font_bold, fill=TEXT_DARK)

    # Inactive tabs
    draw.text((right_x1 + 135, tmux_y + 5), "2:neovim", font=font_sm, fill=TEXT_MUTED)
    draw.text((right_x1 + 215, tmux_y + 5), "3:server", font=font_sm, fill=TEXT_MUTED)
    draw.text((right_x2 - 160, tmux_y + 5), "Shaan @ workstation", font=font_sm, fill=ACCENT_BLUE)

    # Terminal Content
    ty = tmux_y + tmux_h + 12
    term_x = right_x1 + 16

    # Fastfetch block
    ff_lines = [
        ("       /\\          ", ACCENT_CYAN, "shaan@developer-workstation", ACCENT_CYAN),
        ("      /  \\         ", ACCENT_CYAN, "---------------------------", TEXT_MUTED),
        ("     /\\   \\        ", ACCENT_CYAN, "OS: Arch Linux x86_64", TEXT_FG),
        ("    /      \\       ", ACCENT_CYAN, "Host: Workstation Pro Developer Edition", TEXT_FG),
        ("   /   ,,   \\      ", ACCENT_CYAN, "Kernel: 6.8.9-arch1-1", TEXT_FG),
        ("  /   |  |  -\\     ", ACCENT_CYAN, "Uptime: 5 hours, 42 mins", TEXT_FG),
        (" /_-''    ''-_\\    ", ACCENT_CYAN, "Compositor: Hyprland / i3 (Parity)", ACCENT_CYAN),
        ("                   ", TEXT_MUTED, "Terminal: Kitty (Nordic Charcoal Spec)", TEXT_FG),
        ("                   ", TEXT_MUTED, "Shell: Bash 5.2.21 + Starship 1.18", TEXT_FG),
        ("                   ", TEXT_MUTED, "Memory: 3.20 GiB / 15.82 GiB (20%)", ACCENT_PURPLE),
        ("                   ", TEXT_MUTED, "Theme: Nordic Charcoal (#89dceb)", ACCENT_CYAN),
    ]

    for logo_part, logo_col, info_part, info_col in ff_lines:
        draw.text((term_x, ty), logo_part, font=font_code, fill=logo_col)
        draw.text((term_x + 160, ty), info_part, font=font_code, fill=info_col)
        ty += 21

    ty += 14

    # Starship Prompt & Automated Test Command
    draw.text((term_x, ty), "┌─ ~/DeveloperDesktop", font=font_code_bold, fill=ACCENT_CYAN)
    draw.text((term_x + 195, ty), "(main ✓)", font=font_code, fill=ACCENT_BLUE)
    ty += 22
    draw.text((term_x, ty), "└─> ", font=font_code_bold, fill=ACCENT_CYAN)
    draw.text((term_x + 36, ty), "python3 scripts/test_desktop.py", font=font_code_bold, fill=TEXT_FG)
    ty += 26

    # Verification banner
    draw.text((term_x, ty), "======================================================", font=font_code, fill=BORDER_SUBTLE)
    ty += 20
    draw.text((term_x, ty), "  Developer Desktop - Automated Verification Suite    ", font=font_code_bold, fill=ACCENT_CYAN)
    ty += 20
    draw.text((term_x, ty), "======================================================", font=font_code, fill=BORDER_SUBTLE)
    ty += 22

    tests_output = [
        (">> 1. Verifying Shell Script Syntax & Permissions...", ACCENT_YELLOW),
        ("  [PASS] Syntax validation: install.sh (Clean syntax)", ACCENT_GREEN),
        ("  [PASS] Syntax validation: scripts/sys_metrics.sh", ACCENT_GREEN),
        (">> 2. Testing System Metrics Engine (sys_metrics.sh)...", ACCENT_YELLOW),
        ("  [PASS] Metrics --cpu flag (CPU 12%)", ACCENT_GREEN),
        ("  [PASS] Metrics --ram flag (RAM 3.2G/16G (20%))", ACCENT_GREEN),
        ("  [PASS] Metrics --battery flag (BAT 98% [Full])", ACCENT_GREEN),
        ("  [PASS] Metrics --json full schema validation", ACCENT_GREEN),
        ("  [PASS] Metrics --refresh IPC signal trigger (RTMIN+8)", ACCENT_GREEN),
        (">> 3. Testing Window Manager & Developer Tooling...", ACCENT_YELLOW),
        ("  [PASS] Hyprland & i3 keybinding parity (Zero collisions)", ACCENT_GREEN),
        ("  [PASS] Neovim Nordic Charcoal syntax & statusline", ACCENT_GREEN),
        ("  [PASS] Starship prompt structure & accent tokens", ACCENT_GREEN),
        ("------------------------------------------------------", BORDER_SUBTLE),
        ("Total Tests Executed : 54  |  Passed: 54  |  Failed: 0", ACCENT_GREEN),
        ("All Tests Passed with Zero Failures! Production Grade.", ACCENT_GREEN),
    ]

    for line_text, col in tests_output:
        draw.text((term_x, ty), line_text, font=font_code, fill=col)
        ty += 20

    ty += 12
    draw.text((term_x, ty), "┌─ ~/DeveloperDesktop", font=font_code_bold, fill=ACCENT_CYAN)
    draw.text((term_x + 195, ty), "(main ✓)", font=font_code, fill=ACCENT_BLUE)
    ty += 22
    draw.text((term_x, ty), "└─> ", font=font_code_bold, fill=ACCENT_CYAN)
    # Cursor block
    draw.rectangle((term_x + 36, ty + 2, term_x + 46, ty + 18), fill=ACCENT_CYAN)

    im.save(output_path, "PNG")
    print(f"Generated workstation screenshot: {output_path}")

def generate_launcher_screenshot(output_path, workstation_bg_path):
    # Base from workstation screenshot
    base = Image.open(workstation_bg_path).convert("RGBA")
    width, height = base.size

    # Dim overlay
    dim = Image.new("RGBA", (width, height), (11, 11, 27, 205))
    composite = Image.alpha_composite(base, dim)
    draw = ImageDraw.Draw(composite)

    font_xs = get_font(12)
    font_sm = get_font(14)
    font_base = get_font(16)
    font_bold = get_font(16, bold=True)
    font_lg = get_font(20, bold=True)
    font_search = get_font(18)

    # Spotlight Rofi Launcher Window
    w_width = 780
    w_height = 490
    wx1 = (width - w_width) // 2
    wy1 = (height - w_height) // 2
    wx2 = wx1 + w_width
    wy2 = wy1 + w_height

    # Shadow
    for offset in range(8, 0, -2):
        draw_rounded_rect(draw, (wx1 - offset, wy1 - offset, wx2 + offset, wy2 + offset), radius=14, fill=(0, 0, 0, 20))

    # Modal Body
    draw_rounded_rect(draw, (wx1, wy1, wx2, wy2), radius=12, fill=BG_SURFACE, outline=BORDER_ACCENT, width=2)

    # Search Box (Input Bar)
    sb_margin = 16
    sb_h = 50
    sb_y1 = wy1 + sb_margin
    sb_y2 = sb_y1 + sb_h
    draw_rounded_rect(draw, (wx1 + sb_margin, sb_y1, wx2 - sb_margin, sb_y2), radius=8, fill=BG_PANEL, outline=BORDER_SUBTLE, width=1)

    # Search icon & placeholder
    draw.text((wx1 + sb_margin + 16, sb_y1 + 14), ">", font=font_search, fill=ACCENT_CYAN)
    draw.text((wx1 + sb_margin + 36, sb_y1 + 14), "Search applications, projects, or commands...", font=font_search, fill=TEXT_MUTED)

    # Application Entries
    items = [
        ("Terminal", "Kitty GPU Terminal", "Hardware-accelerated terminal", "Super + Return", False),
        ("Editor", "Neovim Cockpit", "Minimalist, zero-dependency IDE", "nvim", False),
        ("Browser", "Firefox Developer", "Auto-routed to Workspace 2", "Super + 2", False),
        ("Monitor", "System Monitor (btop)", "Interactive performance dashboard", "Super + M", True), # SELECTED
        ("Projects", "Project Picker", "Fuzzy search code repositories", "Super + O", False),
        ("Code", "Visual Studio Code", "Auto-routed to Workspace 1", "code", False),
        ("Keys", "Keyboard Cheatsheet", "Searchable shortcuts reference", "Super + Shift + /", False),
        ("Power", "Power Management", "Lock, Suspend, Logout, Reboot", "Super + Shift + E", False),
    ]

    iy = sb_y2 + 14
    item_h = 40
    for tag, name, desc, shortcut, selected in items:
        ix1 = wx1 + sb_margin
        ix2 = wx2 - sb_margin
        iy1 = iy
        iy2 = iy + item_h

        if selected:
            draw_rounded_rect(draw, (ix1, iy1, ix2, iy2), radius=6, fill=ACCENT_CYAN)
            # Badge
            draw_rounded_rect(draw, (ix1 + 10, iy1 + 8, ix1 + 78, iy1 + 32), radius=4, fill="#11111b")
            draw.text((ix1 + 16, iy1 + 11), tag, font=font_xs, fill=ACCENT_CYAN)
            draw.text((ix1 + 92, iy1 + 9), name, font=font_bold, fill=TEXT_DARK)
            draw.text((ix1 + 310, iy1 + 11), desc, font=font_sm, fill="#181825")
            draw.text((ix2 - 140, iy1 + 10), shortcut, font=font_sm, fill=TEXT_DARK)
        else:
            # Badge
            draw_rounded_rect(draw, (ix1 + 10, iy1 + 8, ix1 + 78, iy1 + 32), radius=4, fill=BG_PANEL, outline=BORDER_SUBTLE)
            draw.text((ix1 + 16, iy1 + 11), tag, font=font_xs, fill=ACCENT_CYAN)
            draw.text((ix1 + 92, iy1 + 9), name, font=font_base, fill=TEXT_FG)
            draw.text((ix1 + 310, iy1 + 11), desc, font=font_sm, fill=TEXT_MUTED)
            draw.text((ix2 - 140, iy1 + 10), shortcut, font=font_sm, fill=TEXT_MUTED)

        iy += item_h + 3

    # Bottom helper bar
    draw.line((wx1 + 16, wy2 - 36, wx2 - 16, wy2 - 36), fill=BORDER_SUBTLE, width=1)
    draw.text((wx1 + 20, wy2 - 26), "[Enter] Launch", font=font_sm, fill=ACCENT_CYAN)
    draw.text((wx1 + 160, wy2 - 26), "[Tab] Complete", font=font_sm, fill=TEXT_MUTED)
    draw.text((wx1 + 300, wy2 - 26), "[Alt+1..9] Jump Workspace", font=font_sm, fill=TEXT_MUTED)
    draw.text((wx2 - 130, wy2 - 26), "[Esc] Dismiss", font=font_sm, fill=ACCENT_RED)

    composite.convert("RGB").save(output_path, "PNG")
    print(f"Generated launcher screenshot: {output_path}")

if __name__ == "__main__":
    repo_root = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
    ws_path = os.path.join(repo_root, "screenshot_workstation.png")
    launcher_path = os.path.join(repo_root, "screenshot_launcher.png")
    hero_path = os.path.join(repo_root, "screenshot.png")

    generate_workstation_screenshot(ws_path)
    generate_launcher_screenshot(launcher_path, ws_path)
    # Hero is a copy of workstation
    import shutil
    shutil.copyfile(ws_path, hero_path)
    print("All screenshots generated successfully!")
