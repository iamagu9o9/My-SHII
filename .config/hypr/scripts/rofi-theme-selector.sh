#!/usr/bin/env bash

# Rofi Theme Options
CHOSEN=$(echo -e "1. Dynamic Wallpaper Colors\n2. Pure Monochrome Gray\n3. High Contrast Vivid\n4. Select New Wallpaper" | rofi -dmenu -i -p "Theme:")

# Get current wallpaper path or fallback
CURRENT_WALL=$(swww query 2>/dev/null | awk -F 'image: ' '{print $2}' | head -n 1)

if [ -z "$CURRENT_WALL" ] || [ ! -f "$CURRENT_WALL" ]; then
    CURRENT_WALL=$(find ~/Pictures/Wallpapers -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" -o -name "*.webp" \) | head -n 1)
fi

case "$CHOSEN" in
    *"Dynamic Wallpaper Colors"*)
        wal -i "$CURRENT_WALL" -n -q --backend colorz --saturate 0.8 -b 000000
        ~/.config/waybar/scripts/wal-waybar.sh
        killall -USR1 kitty 2>/dev/null
        ;;
    *"Pure Monochrome Gray"*)
        wal -i "$CURRENT_WALL" -n -q --saturate -1.0 -b 000000
        ~/.config/waybar/scripts/wal-waybar.sh
        killall -USR1 kitty 2>/dev/null
        ;;
    *"High Contrast Vivid"*)
        wal -i "$CURRENT_WALL" -n -q --backend colorz --saturate 1.0 -b 000000
        ~/.config/waybar/scripts/wal-waybar.sh
        killall -USR1 kitty 2>/dev/null
        ;;
    *"Select New Wallpaper"*)
        /home/iamagu/.config/hypr/scripts/wallpaper-selector.sh
        ;;
esac
