# Contributing to DeveloperDesktop

Thank you for your interest in contributing to **DeveloperDesktop**! We welcome improvements, bug reports, and optimizations that enhance the keyboard-driven workflow while maintaining our strict minimalist aesthetic.

---

## 📐 Core Design Philosophy

Before submitting a change, please ensure your contribution aligns with our core design tenets:
1. **Mathematical Symmetry:** Strict 8px grid alignment across tiled windows and floating panels.
2. **Nordic Charcoal Spec:** Surface `#11111b`, surface variant `#181825`, text `#cdd6f4`, accent `#89dceb`. Avoid introducing unharmonious accent colors.
3. **Sub-Millisecond Performance:** Scripts must use native `/proc` or built-in shell primitives rather than spawning heavy external runtimes.
4. **Universal Parity:** Where applicable, ensure feature parity between Hyprland (Wayland) and i3 (X11 / WSLg).
5. **Zero Hardcoded Paths:** Always use `$HOME`, `${XDG_CONFIG_HOME}`, or relative references. Never hardcode usernames or machine-specific mount points.

---

## 🛠️ Development & Testing Workflow

### 1. Branching
Create a feature branch from `main`:
```bash
git checkout -b feat/your-feature-name
```

### 2. Git Commit Convention
Follow our **Plain English Commit Convention** (ADR-003):
- Write clear, direct, imperative sentences.
- Do NOT use brackets, robotic tags, or prefixes like `feat:` or `fix:`.
- Examples:
  - `Add Neovim configuration matching Nordic Charcoal`
  - `Fix Waybar power menu on-click execution`
  - `Upgrade installer with rollback support`

### 3. Local Verification
Before opening a Pull Request, run the automated verification suite:
```bash
# In Linux or WSL:
python3 scripts/test_desktop.py
```
All 54+ tests must pass with zero failures.

---

## 📋 Pull Request Checklist

- [ ] All shell scripts have valid syntax (`bash -n`) and executable permissions.
- [ ] No hardcoded usernames or local `file:///` URIs.
- [ ] New features are documented in `README.md`.
- [ ] Verification test suite passes 100% (`python3 scripts/test_desktop.py`).
- [ ] Changes do not break installer idempotency (`./install.sh --dry-run`).
