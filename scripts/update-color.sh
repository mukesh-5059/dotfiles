#!/bin/bash
# Variables
SELECTED_WALLPAPER=$1
WALLPAPER_DIR="$HOME/wallpapers/wallpapers"
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
pywalfox update
killall eww
eww open-many bar
swaync-client -rs
killall swayosd-server && swayosd-server &
killall hyprpaper
hyprpaper &

#if pgrep -x nautilus >/dev/null; then
#    nautilus -q
#fi

# Update Papirus folder icon colors to match the wallpaper
#SCRIPTPATH="$(cd "$(dirname "$0")" && pwd)"
#if hash papirus-folders 2>/dev/null; then
#    FOLDER_COLOR=$(python3 "$SCRIPTPATH/match_folder_color.py")
#    echo "Updating folder icons to match: $FOLDER_COLOR..."
#    papirus-folders -C "$FOLDER_COLOR" --theme Papirus-Dark
#fi
# Restart Conky to capture the updated wallpaper pixmap
if pgrep -x conky >/dev/null; then
    killall conky
    sleep 0.5
    conky -c ~/modified-zenities/.config/conky/conky_sidebar.conf &
fi

echo "Done."