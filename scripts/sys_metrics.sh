#!/usr/bin/env bash
# ==============================================================================
#  sys_metrics.sh - Refreshable Modular System Performance Monitor
#  Maintained by: Shaan
# ==============================================================================
#  Supports CLI output, Waybar JSON streaming, and signal-triggered refreshes.
#  Auto-detects laptops (Battery) vs Desktops/VMs (Disk usage fallback).
# ==============================================================================

set -o pipefail

# --- CPU Percentage Calculation ---
get_cpu() {
    # Read two samples from /proc/stat for accurate calculation without top overhead
    if [[ -f /proc/stat ]]; then
        read -r cpu user nice system idle iowait irq softirq steal _ < /proc/stat
        prev_idle=$((idle + iowait))
        prev_total=$((user + nice + system + idle + iowait + irq + softirq + steal))
        sleep 0.2
        read -r cpu user nice system idle iowait irq softirq steal _ < /proc/stat
        curr_idle=$((idle + iowait))
        curr_total=$((user + nice + system + idle + iowait + irq + softirq + steal))

        diff_idle=$((curr_idle - prev_idle))
        diff_total=$((curr_total - prev_total))
        if (( diff_total > 0 )); then
            cpu_usage=$(( (1000 * (diff_total - diff_idle) / diff_total + 5) / 10 ))
        else
            cpu_usage=0
        fi
    else
        cpu_usage=$(top -bn1 2>/dev/null | awk '/Cpu\(s\)/ {print int($2 + $4)}') || cpu_usage=0
    fi
    # Clamp bounds to 0-100%
    (( cpu_usage < 0 )) && cpu_usage=0
    (( cpu_usage > 100 )) && cpu_usage=100
    echo "$cpu_usage"
}

# --- RAM Memory Usage Calculation ---
get_ram() {
    # Parse /proc/meminfo directly for instant microsecond execution
    if [[ -f /proc/meminfo ]]; then
        mem_total=$(awk '/MemTotal/ {print $2}' /proc/meminfo || echo 1)
        mem_available=$(awk '/MemAvailable/ {print $2}' /proc/meminfo || true)
        # Fallback for older enterprise kernels where MemAvailable is absent
        if [[ -z "$mem_available" ]]; then
            mem_available=$(awk '/MemFree/ {f=$2} /Buffers/ {b=$2} /Cached/ {c=$2} END {print f+b+c}' /proc/meminfo 2>/dev/null || echo 0)
        fi
        mem_total=${mem_total:-1}
        mem_available=${mem_available:-0}
        mem_used=$((mem_total - mem_available))
        (( mem_used < 0 )) && mem_used=0
        ram_percent=$(( 100 * mem_used / mem_total ))
        (( ram_percent > 100 )) && ram_percent=100
        ram_used_gb=$(awk "BEGIN {printf \"%.1f\", $mem_used / 1048576}")
        ram_total_gb=$(awk "BEGIN {printf \"%.1f\", $mem_total / 1048576}")
    else
        ram_percent=0
        ram_used_gb="0.0"
        ram_total_gb="0.0"
    fi
    echo "$ram_percent $ram_used_gb $ram_total_gb"
}

# --- Battery & Desktop Fallback ---
get_battery() {
    bat_path=""
    for bat in /sys/class/power_supply/BAT*; do
        if [[ -d "$bat" ]]; then
            bat_path="$bat"
            break
        fi
    done

    if [[ -n "$bat_path" && -f "$bat_path/capacity" ]]; then
        capacity=$(cat "$bat_path/capacity" 2>/dev/null || echo 0)
        status=$(cat "$bat_path/status" 2>/dev/null || echo "Unknown")
        # Sanitize status to prevent word-splitting (e.g. 'Not charging' -> 'Not-charging')
        status="${status// /-}"
        (( capacity < 0 )) && capacity=0
        (( capacity > 100 )) && capacity=100
        icon="󰁹"
        if (( capacity < 20 )); then icon="󰁺";
        elif (( capacity < 50 )); then icon="󰁼";
        elif (( capacity < 80 )); then icon="󰁾"; fi
        if [[ "$status" == "Charging" ]]; then icon="󰂄"; fi
        echo "battery $capacity $status $icon"
    else
        # Desktop / VM Fallback: Show Root Disk Usage (POSIX df -Ph for universal single-line parsing)
        disk_used_percent=$(LC_ALL=C df -Ph / 2>/dev/null | awk 'END {print int($5)}') || disk_used_percent=0
        disk_avail=$(LC_ALL=C df -Ph / 2>/dev/null | awk 'END {print $4}') || disk_avail="0G"
        echo "desktop $disk_used_percent $disk_avail 󰋊"
    fi
}

# --- Trigger Immediate Bar Refresh (Bonus: Event-Driven Optimization) ---
trigger_refresh() {
    local signaled=false
    # Send custom Real-Time Signal to Waybar to trigger instant update without polling
    if pgrep -x waybar > /dev/null; then
        pkill -RTMIN+8 waybar 2>/dev/null || true
        echo "Sent instant refresh signal to Waybar (RTMIN+8)"
        signaled=true
    fi
    # If running under i3, notify or reload bar
    if command -v i3-msg &>/dev/null && pgrep -x i3 > /dev/null; then
        i3-msg -q restart 2>/dev/null || true
        echo "Sent instant refresh trigger to i3"
        signaled=true
    fi
    if [[ "$signaled" == false ]]; then
        echo "Waybar/i3bar not currently running (signal queued)"
    fi
}

# --- CLI & JSON Output Dispatcher ---
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
mode="${1:---all}"

case "$mode" in
    --cpu)
        usage=$(get_cpu)
        echo "󰍛 ${usage}%"
        ;;
    --ram|--mem)
        read -r ram_pct ram_used ram_tot <<< "$(get_ram)"
        echo "󰘚 ${ram_used}G/${ram_tot}G (${ram_pct}%)"
        ;;
    --battery)
        read -r type val extra icon <<< "$(get_battery)"
        if [[ "$type" == "battery" ]]; then
            echo "$icon ${val}% [${extra}]"
        else
            echo "$icon Disk: ${val}% (${extra} free)"
        fi
        ;;
    --refresh)
        trigger_refresh
        ;;
    --json)
        usage=$(get_cpu)
        read -r ram_pct ram_used ram_tot <<< "$(get_ram)"
        read -r bat_type bat_val bat_extra bat_icon <<< "$(get_battery)"

        class="normal"
        if (( usage > 90 )) || (( ram_pct > 90 )); then
            class="critical"
        elif (( usage > 75 )) || (( ram_pct > 75 )); then
            class="warning"
        fi

        if [[ "$bat_type" == "battery" ]]; then
            text="󰍛 ${usage}%  󰘚 ${ram_used}G  ${bat_icon} ${bat_val}%"
            tooltip="CPU: ${usage}%\nRAM: ${ram_used}G / ${ram_tot}G (${ram_pct}%)\nBattery: ${bat_val}% (${bat_extra})"
        else
            text="󰍛 ${usage}%  󰘚 ${ram_used}G  ${bat_icon} ${bat_val}%"
            tooltip="CPU: ${usage}%\nRAM: ${ram_used}G / ${ram_tot}G (${ram_pct}%)\nDisk: ${bat_val}% used (${bat_extra} free)"
        fi

        # Format JSON for Waybar custom module & external consumers
        printf '{"text":"%s","tooltip":"%s","class":"%s","percentage":%d,"cpu_percent":%d,"ram_percent":%d,"ram_used_gb":"%s","ram_total_gb":"%s"}\n' \
            "$text" "$tooltip" "$class" "$usage" "$usage" "$ram_pct" "$ram_used" "$ram_tot"
        ;;
    --bar|--compact)
        usage=$(get_cpu)
        read -r ram_pct ram_used ram_tot <<< "$(get_ram)"
        read -r bat_type bat_val bat_extra bat_icon <<< "$(get_battery)"
        timestamp=$(date +'%H:%M:%S  %a %d %b')
        if [[ "$bat_type" == "battery" ]]; then
            echo "󰍛 ${usage}%  |  󰘚 ${ram_used}G/${ram_tot}G (${ram_pct}%)  |  ${bat_icon} ${bat_val}%  |   ${timestamp}"
        else
            echo "󰍛 ${usage}%  |  󰘚 ${ram_used}G/${ram_tot}G (${ram_pct}%)  |  ${bat_icon} ${bat_val}% used (${bat_extra} free)  |   ${timestamp}"
        fi
        ;;
    --version|-v)
        echo "sys_metrics.sh v2.0.0 (DeveloperDesktop Edition)"
        ;;
    --help|-h)
        echo "Usage: sys_metrics.sh [OPTION]"
        echo "Modular, sub-millisecond system performance monitor."
        echo ""
        echo "Options:"
        echo "  --all            Print complete human-readable report (default)"
        echo "  --cpu            Print formatted CPU usage percentage"
        echo "  --ram, --mem     Print formatted RAM memory usage"
        echo "  --battery        Print battery status or desktop storage fallback"
        echo "  --bar, --compact Formatted single-line status stream for status bars"
        echo "  --json           Output Waybar-compliant JSON payload"
        echo "  --refresh        Send instant real-time signal to Waybar (RTMIN+8)"
        echo "  --version, -v    Show version number"
        echo "  --help, -h       Show this help message"
        ;;
    --all|*)
        usage=$(get_cpu)
        read -r ram_pct ram_used ram_tot <<< "$(get_ram)"
        read -r bat_type bat_val bat_extra bat_icon <<< "$(get_battery)"

        echo "=========================================="
        echo "  Developer Workstation System Metrics    "
        echo "=========================================="
        echo "  CPU Usage     : ${usage}%"
        echo "  RAM Memory    : ${ram_used} GB / ${ram_tot} GB (${ram_pct}%)"
        if [[ "$bat_type" == "battery" ]]; then
            echo "  Battery Level : ${bat_val}% (${bat_extra})"
        else
            echo "  Root Storage  : ${bat_val}% used (${bat_extra} free)"
        fi
        echo "=========================================="
        ;;
esac
fi
