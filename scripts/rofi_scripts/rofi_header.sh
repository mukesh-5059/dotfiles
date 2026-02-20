#!/bin/sh
# =============================================================
# Author:  gh0stzk
# Repo:    https://github.com/gh0stzk/dotfiles
# Date:    28.01.2026
# rofi_header: Regenerate the rofi header image from the current wallpaper.
# Copyright (C) 2021-2026 gh0stzk <z0mbi3.zk@protonmail.com>
# Licensed under GPL-3.0 license
# =============================================================

CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}"
HASH_FILE="$CACHE_DIR/current_wall.hash"

# Common magick parameters
MAGICK_PARAMS="-strip -resize 30% -gravity center -crop 760x196+0+0 +repage -quality 65 -define webp:method=3 -define webp:thread-level=1"

mkdir -p "$CACHE_DIR"

generate_header() {
    INPUT="$1"
    magick "$INPUT" $MAGICK_PARAMS "$CACHE_DIR/rofi_header.webp"
}

# Get current wallpaper from hyprpaper.conf
WALL=$(grep 'path\s*=' "$HOME/.config/hypr/hyprpaper.conf" | sed 's/.*=\s*//' | sed "s|\$HOME|$HOME|") 
[ -z "$WALL" ] && exit 1

# Create symbolic link for current wallpaper
ln -sf "$WALL" "$CACHE_DIR/current_wall"

NEW_HASH=$(md5sum "$WALL" | cut -d' ' -f1)
OLD_HASH=$(cat "$HASH_FILE" 2>/dev/null)

if [ "$NEW_HASH" != "$OLD_HASH" ]; then
    echo "$NEW_HASH" > "$HASH_FILE"
    generate_header "$WALL"
fi

exit 0