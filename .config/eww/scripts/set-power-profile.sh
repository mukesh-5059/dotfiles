#!/bin/bash

# --- CONFIGURATION ---
readonly SOUND_SUCCESS="/usr/share/sounds/freedesktop/stereo/bell.oga"
readonly SOUND_ERROR="/usr/share/sounds/freedesktop/stereo/suspend-error.oga"

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

PROFILE=""

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --profile) PROFILE="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

if [ -z "$PROFILE" ]; then
  echo "Usage: $0 --profile <profile_name>"
  echo "Available profiles: performance, balanced, power-saver"
  exit 1
fi

PROFILE_NAME=""
ICON=""

# Set the power profile and determine the notification message
case "$PROFILE" in
  "performance")
    PROFILE_NAME="Performance"
    ICON="power-profile-performance-symbolic"
    ;;
  "balanced")
    PROFILE_NAME="Balanced"
    ICON="power-profile-balanced-symbolic"
    ;;
  "power-saver")
    PROFILE_NAME="Power Saver"
    ICON="power-profile-power-saver-symbolic"
    ;;
  *)
    send_notification "Power Profile Error" "Invalid profile: $PROFILE" "dialog-error" "$SOUND_ERROR"
    exit 1
    ;;
esac

# Set the power profile
if powerprofilesctl set "$PROFILE"; then
    # Send notification on success
    send_notification "Power Profile" "$PROFILE_NAME mode activated" "$ICON" "$SOUND_SUCCESS"
else
    # Send error notification
    send_notification "Power Profile Error" "Failed to set $PROFILE_NAME mode" "dialog-error" "$SOUND_ERROR"
fi

exit 0
