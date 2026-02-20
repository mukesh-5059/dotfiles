#!/bin/bash

# --- CONFIGURATION ---
readonly SOUND_ENABLED="/usr/share/sounds/freedesktop/stereo/device-added.oga"
readonly SOUND_DISABLED="/usr/share/sounds/freedesktop/stereo/device-removed.oga"
readonly ICON_ENABLED="dialog-information" 
readonly ICON_DISABLED="dialog-warning" 

# --- FUNCTIONS ---
send_notification() {
    local title="$1"
    local body="$2"
    local icon="$3"
    local sound="$4"

    notify-send "$title" "$body" -i "$icon"
    if command -v paplay &>/dev/null && [ -f "$sound" ]; then
        paplay "$sound" &
    fi
}

# Check if HyprIdle is running
if pgrep -x "hypridle" > /dev/null; then
    # If HyprIdle is running, kill it to enable "Do Not Sleep"
    pkill -x "hypridle"
    send_notification "Do Not Sleep Enabled" "Automatic sleeping is now disabled." "$ICON_ENABLED" "$SOUND_ENABLED"
else
    # If HyprIdle is not running, start it to disable "Do Not Sleep"
    hypridle &
    send_notification "Do Not Sleep Disabled" "Automatic sleeping is now enabled." "$ICON_DISABLED" "$SOUND_DISABLED"
fi