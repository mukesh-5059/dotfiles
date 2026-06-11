#!/bin/bash

# Path to the conservation mode file
FILE="/sys/bus/platform/drivers/ideapad_acpi/VPC2004:00/conservation_mode"

# Check the current status
STATUS=$(cat "$FILE")

if [ "$STATUS" -eq 0 ]; then
    # It's off, so turn it on
    sudo systemctl start battery-conservation.service
    notify-send "Battery" "Conservation Mode ENABLED (Cap at 60%)" -i battery-charging
else
    # It's on, so turn it off
    # We stop the service AND manually set it to 0
    sudo systemctl stop battery-conservation.service
    echo 0 | sudo tee "$FILE"
    notify-send "Battery" "Conservation Mode DISABLED (Charge to 100%)" -i battery-full
fi