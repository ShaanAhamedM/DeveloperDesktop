@echo off
title Developer Desktop - Minimalist Cockpit
cd /d "%~dp0"
echo ========================================================
echo   Launching Minimalist Developer Desktop via WSLg...
echo ========================================================
wsl bash -c "chmod +x ./scripts/*.sh && ./scripts/launch_desktop.sh"
pause
