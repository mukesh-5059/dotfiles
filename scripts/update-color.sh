#!/bin/bash
# Variables
SELECTED_WALLPAPER=$1
WALLPAPER_DIR="$HOME/wallpapers"
# Ensure the wallpaper exists
if [ ! -f "$WALLPAPER_DIR/$SELECTED_WALLPAPER.jpg" ]; then
    echo "Error: Wallpaper not found: $SELECTED_WALLPAPER"
    exit 1
fi
echo "Attempting to generate color scheme..."
# Try to apply colors, but don't exit if it fails
if wallust run "$WALLPAPER_DIR/$SELECTED_WALLPAPER.jpg" && wal -i "$WALLPAPER_DIR/$SELECTED_WALLPAPER.jpg"; then
    echo "Color scheme generated successfully. Reloading widgets..."
else
    echo "Warning: Failed to generate and apply color scheme for this wallpaper."
    echo "The old color scheme will be kept, but the wallpaper will be updated."
fi
# Always restart hyprpaper to set the new wallpaper
echo "Setting new wallpaper..."
killall eww
eww open-many bar
swaync-client -rs
killall hyprpaper
hyprpaper &
echo "Done."