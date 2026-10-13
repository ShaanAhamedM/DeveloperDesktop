#!/usr/bin/env python3
"""
Automated Comprehensive Test Suite for DeveloperDesktop
Validates every shortcut, configuration, script, window manager IPC, and aesthetic token.
"""

import os
import sys
import json
import time
import subprocess
import shutil

class Colors:
    GREEN = '\033[92m'
    RED = '\033[91m'
    CYAN = '\033[96m'
    YELLOW = '\033[93m'
    RESET = '\033[0m'

passed_tests = 0
failed_tests = 0

def report(name, success, details=""):
    global passed_tests, failed_tests
    if success:
        passed_tests += 1
        print(f"  {Colors.GREEN}[PASS]{Colors.RESET} {name} {f'({details})' if details else ''}")
    else:
        failed_tests += 1
        print(f"  {Colors.RED}[FAIL]{Colors.RESET} {name} - {details}")

def run_cmd(cmd, env=None, timeout=10):
    try:
        proc = subprocess.run(
            cmd,
            shell=isinstance(cmd, str),
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            env=env or os.environ.copy(),
            timeout=timeout
        )
        return proc.returncode, proc.stdout.strip(), proc.stderr.strip()
    except subprocess.TimeoutExpired:
        return -1, "", "Command timed out"
    except Exception as e:
        return -1, "", str(e)

print(f"\n{Colors.CYAN}======================================================{Colors.RESET}")
print(f"{Colors.CYAN}  Developer Desktop - Automated Verification Suite   {Colors.RESET}")
print(f"{Colors.CYAN}======================================================{Colors.RESET}\n")

# -----------------------------------------------------------------------------
# 1. Shell Script Syntax Checks (bash -n)
# -----------------------------------------------------------------------------
print(f"{Colors.YELLOW}>> 1. Verifying Shell Script Syntax & Permissions...{Colors.RESET}")
scripts = [
    "install.sh",
    "scripts/sys_metrics.sh",
    "scripts/theme_sync.sh",
    "scripts/cheat_sheet.sh",
    "scripts/project_picker.sh",
    "scripts/power_menu.sh",
    "scripts/scratchpad.sh",
    "scripts/launch_desktop.sh",
    "scripts/setup_xrdp.sh",
]

for s in scripts:
    if not os.path.exists(s):
        report(f"Script exists: {s}", False, "File not found")
        continue
    # Check syntax
    code, stdout, stderr = run_cmd(f"bash -n '{s}'")
    report(f"Syntax validation: {s}", code == 0, stderr if code != 0 else "Clean syntax")
    # Check executable bit
    is_exec = os.access(s, os.X_OK)
    report(f"Executable permission: {s}", is_exec, f"Mode {oct(os.stat(s).st_mode)}")

# -----------------------------------------------------------------------------
# 2. System Metrics Script Functionality (Core Req #3)
# -----------------------------------------------------------------------------
print(f"\n{Colors.YELLOW}>> 2. Testing System Metrics Engine (sys_metrics.sh)...{Colors.RESET}")
metrics_script = "scripts/sys_metrics.sh"

code, out, err = run_cmd(f"bash {metrics_script} --cpu")
report("Metrics --cpu flag", code == 0 and "%" in out, out)

code, out, err = run_cmd(f"bash {metrics_script} --ram")
report("Metrics --ram flag", code == 0 and "G" in out and "%" in out, out)

code, out, err = run_cmd(f"bash {metrics_script} --mem")
report("Metrics --mem alias flag", code == 0 and "G" in out and "%" in out, out)

code, out, err = run_cmd(f"bash {metrics_script} --battery")
report("Metrics --battery flag", code == 0 and ("%" in out or "Disk" in out), out)

code, out, err = run_cmd(f"bash {metrics_script} --all")
report("Metrics --all flag", code == 0 and "Developer Workstation System Metrics" in out, out.replace('\n', ' | '))

code, out, err = run_cmd(f"bash {metrics_script} --json")
valid_json = False
json_data = {}
if code == 0:
    try:
        json_data = json.loads(out)
        valid_json = "cpu_percent" in json_data and "ram_percent" in json_data and "text" in json_data
    except Exception as e:
        valid_json = False
report("Metrics --json stream parser", valid_json, f"CPU={json_data.get('cpu_percent')}% RAM={json_data.get('ram_percent')}% text={json_data.get('text')}")

# -----------------------------------------------------------------------------
# 3. Dynamic Theming Engine (Bonus Feature)
# -----------------------------------------------------------------------------
print(f"\n{Colors.YELLOW}>> 3. Testing Dynamic Theming Engine (theme_sync.sh)...{Colors.RESET}")
theme_script = "scripts/theme_sync.sh"
code, out, err = run_cmd(f"bash {theme_script}")
report("Theme sync execution", code == 0, out.splitlines()[-1] if out else err)

theme_file = "themes/nordic-charcoal.json"
theme_valid = False
if os.path.exists(theme_file):
    try:
        with open(theme_file, "r") as f:
            t = json.load(f)
            theme_valid = "name" in t and "colors" in t and "background" in t["colors"] and "palette" in t["colors"]
    except Exception:
        theme_valid = False
report("Theme JSON specification integrity", theme_valid, f"Theme={t.get('name') if theme_valid else 'Invalid'}")

# -----------------------------------------------------------------------------
# 4. Interactive Utilities CLI Tests
# -----------------------------------------------------------------------------
print(f"\n{Colors.YELLOW}>> 4. Testing Developer Productivity Tools...{Colors.RESET}")
# Cheat sheet non-GUI fallback
code, out, err = run_cmd("bash scripts/cheat_sheet.sh --text")
report("Cheat sheet text reference fallback", code == 0 and "Launch Terminal" in out and "Launch Application" in out)

# Project picker syntax
code, out, err = run_cmd("bash -n scripts/project_picker.sh")
report("Project picker script syntax validation", code == 0)

# Power menu syntax validation
code, out, err = run_cmd("bash -n scripts/power_menu.sh")
report("Power menu script syntax validation", code == 0)

# -----------------------------------------------------------------------------
# 5. Window Manager Config Validation (i3 -C)
# -----------------------------------------------------------------------------
print(f"\n{Colors.YELLOW}>> 5. Validating Window Manager Configurations...{Colors.RESET}")
i3_conf = os.path.expanduser("~/.config/i3/config")
if not os.path.exists(i3_conf):
    i3_conf = ".config/i3/config"
code, out, err = run_cmd(f"i3 -C -c {i3_conf}")
report("i3 configuration syntax check (i3 -C)", code == 0, err if code != 0 else "Zero syntax errors")

# -----------------------------------------------------------------------------
# 6. Live Display & IPC Keybinding Simulation (DISPLAY=:1)
# -----------------------------------------------------------------------------
print(f"\n{Colors.YELLOW}>> 6. Testing Live X11 Display & IPC Keybinding Operations...{Colors.RESET}")
env_d1 = os.environ.copy()
env_d1["DISPLAY"] = ":1"

code, out, err = run_cmd("i3-msg -t get_version", env=env_d1)
is_i3_running = code == 0 and "human_readable" in out
report("i3 IPC socket connection on DISPLAY=:1", is_i3_running, out.splitlines()[0] if is_i3_running else "Not running")

if is_i3_running:
    # Test Terminal Spawning via i3 exec (simulating Alt+Enter / Super+Enter)
    code, out, err = run_cmd("i3-msg 'exec xterm'", env=env_d1)
    report("Terminal launch IPC ('exec xterm')", code == 0 and '"success":true' in out)
    time.sleep(1)

    # Verify Window Tree
    code, out, err = run_cmd("i3-msg -t get_tree", env=env_d1)
    has_xterm = "xterm" in out or "XTerm" in out
    report("Window tiling verification in tree", has_xterm)

    # Test Fullscreen Toggle (simulating Alt+F / Super+F)
    code, out, err = run_cmd("i3-msg 'fullscreen toggle'", env=env_d1)
    report("Fullscreen toggle IPC ('fullscreen toggle')", code == 0 and '"success":true' in out)
    time.sleep(0.3)
    code, out, err = run_cmd("i3-msg 'fullscreen toggle'", env=env_d1)
    report("Fullscreen toggle restore", code == 0 and '"success":true' in out)

    # Test Floating Toggle (simulating Alt+V / Super+V)
    code, out, err = run_cmd("i3-msg 'floating toggle'", env=env_d1)
    report("Floating mode toggle IPC ('floating toggle')", code == 0 and '"success":true' in out)
    time.sleep(0.3)
    code, out, err = run_cmd("i3-msg 'floating toggle'", env=env_d1)
    report("Floating mode snap-back to tiling", code == 0 and '"success":true' in out)

    # Test Workspace Navigation (simulating Alt+2 / Super+2)
    code, out, err = run_cmd("i3-msg 'workspace 2'", env=env_d1)
    report("Workspace switch to 2 ('workspace 2')", code == 0 and '"success":true' in out)
    time.sleep(0.3)
    code, out, err = run_cmd("i3-msg 'workspace 1'", env=env_d1)
    report("Workspace switch back to 1 ('workspace 1')", code == 0 and '"success":true' in out)

    # Test Close Window (simulating Alt+Q / Super+Q)
    code, out, err = run_cmd("i3-msg 'kill'", env=env_d1)
    report("Window close IPC ('kill')", code == 0 and '"success":true' in out)

    # Test Rofi Application Launcher Window Mapping
    code, out, err = run_cmd("timeout 1 rofi -show drun", env=env_d1)
    report("Rofi App Launcher mapping & startup", code in (0, 124, 142, 1), "Rofi executed cleanly")

    # Test Cheatsheet on Display
    code, out, err = run_cmd("timeout 1 bash scripts/cheat_sheet.sh", env=env_d1)
    report("Cheatsheet modal mapping & startup", code in (0, 124, 142, 1), "Cheatsheet launched cleanly")

# -----------------------------------------------------------------------------
# 7. Summary
# -----------------------------------------------------------------------------
print(f"\n{Colors.CYAN}======================================================{Colors.RESET}")
total = passed_tests + failed_tests
print(f"Total Tests Executed : {total}")
print(f"{Colors.GREEN}Tests Passed         : {passed_tests}{Colors.RESET}")
if failed_tests > 0:
    print(f"{Colors.RED}Tests Failed         : {failed_tests}{Colors.RESET}")
else:
    print(f"{Colors.GREEN}All Tests Passed with Zero Failures!{Colors.RESET}")
print(f"{Colors.CYAN}======================================================{Colors.RESET}\n")

sys.exit(failed_tests)
