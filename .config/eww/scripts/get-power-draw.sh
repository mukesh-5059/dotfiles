#!/bin/bash
rate=$(upower -i /org/freedesktop/UPower/devices/battery_BAT0 | awk '/energy-rate:/ {print $2}')
if [ -z "$rate" ] || [ "$rate" = "0" ]; then
    echo "0 W"
else
    printf "%.1f W\n" "$rate"
fi
