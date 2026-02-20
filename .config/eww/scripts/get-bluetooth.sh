#!/bin/bash

# Check if Bluetooth is powered on
BLUETOOTH_STATUS=$(bluetoothctl show | grep "Powered" | awk '{print $2}')

if [[ "$BLUETOOTH_STATUS" == "yes" ]]; then
    # Get all connected Bluetooth devices
    CONNECTED_DEVICES=$(bluetoothctl devices Connected | grep "Device")

    DEVICE_OUTPUT=""
    
    if [[ -n "$CONNECTED_DEVICES" ]]; then
        # Take the first connected device
        DEVICE_LINE=$(echo "$CONNECTED_DEVICES" | head -n 1)
        DEVICE_MAC=$(echo "$DEVICE_LINE" | awk '{print $2}')
        DEVICE_NAME=$(echo "$DEVICE_LINE" | awk '{print substr($0, index($0,$3))}')

        # Try to get battery percentage using bluetoothctl info
        BATTERY_PERCENTAGE_LINE=$(bluetoothctl info "$DEVICE_MAC" | grep "Battery Percentage")
        
        if [[ -n "$BATTERY_PERCENTAGE_LINE" ]]; then
            BATTERY_PERCENTAGE=$(echo "$BATTERY_PERCENTAGE_LINE" | awk -F '[()]' '{print $2}')
            DEVICE_OUTPUT="${DEVICE_NAME} (${BATTERY_PERCENTAGE}%)"
        else
            DEVICE_OUTPUT="$DEVICE_NAME"
        fi
    else
        DEVICE_OUTPUT="None"
    fi
    echo "$DEVICE_OUTPUT"
else
    echo "Off"
fi
