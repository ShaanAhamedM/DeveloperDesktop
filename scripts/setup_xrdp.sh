#!/usr/bin/env bash
# ==============================================================================
#  setup_xrdp.sh - Automated Remote Desktop (RDP) Configurator for WSL
# ==============================================================================

set -euo pipefail

echo ">> Configuring XRDP on port 3390..."

# 1. Update xrdp.ini to port 3390 to prevent collision with Windows host RDP
sed -i 's/^port=3389/port=3390/g' /etc/xrdp/xrdp.ini 2>/dev/null || true

# 2. Configure user session to start i3
cat << 'EOF' > /home/shaan/.xsession
#!/bin/sh
export DESKTOP_SESSION=i3
export XDG_CURRENT_DESKTOP=i3
exec i3
EOF
chmod +x /home/shaan/.xsession
chown shaan:shaan /home/shaan/.xsession

# 3. Deploy dotfiles to user home
mkdir -p /home/shaan/.config
cp -r /mnt/d/OpenSourceProjects/DeveloperDesktop/.config/* /home/shaan/.config/
mkdir -p /home/shaan/.config/scripts
cp -r /mnt/d/OpenSourceProjects/DeveloperDesktop/scripts/* /home/shaan/.config/scripts/
chmod +x /home/shaan/.config/scripts/*.sh
mkdir -p /home/shaan/.config/wallpapers
cp -r /mnt/d/OpenSourceProjects/DeveloperDesktop/wallpapers/* /home/shaan/.config/wallpapers/

chown -R shaan:shaan /home/shaan/.config

# 4. Restart XRDP Service
service xrdp restart

echo ">> XRDP service started on port 3390 successfully!"
