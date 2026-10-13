@echo off
title Developer Desktop - Minimalist Cockpit
echo ========================================================
echo   Launching Minimalist Developer Desktop via WSLg...
echo ========================================================
wsl -u shaan bash -c "chmod +x /mnt/d/OpenSourceProjects/DeveloperDesktop/scripts/*.sh && /mnt/d/OpenSourceProjects/DeveloperDesktop/scripts/launch_desktop.sh"
pause
