#!/bin/bash
rate=$(upower -i /org/freedesktop/UPower/devices/battery_BAT0 | awk '/energy-rate:/ {print $2}')
if [ -z "$rate" ]; then
    echo "0"
else
    # Scale to a maximum of 50 Watts.
    percent=$(awk -v r="$rate" 'BEGIN { p = r * 100 / 50; if (p > 100) p = 100; printf "%d", p }')
    echo "${percent:-0}"
fi
