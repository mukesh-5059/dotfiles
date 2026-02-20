#!/bin/bash

# Check if bluetooth is blocked
if $(rfkill list bluetooth | grep -q 'yes$'); then
    rfkill unblock bluetooth
    sleep 0.1
fi

# Toggle bluetooth
bluetoothctl power $([ $(bluetoothctl show | grep "Powered: yes" | wc -c) -eq 0 ] && echo "on" || echo "off")
