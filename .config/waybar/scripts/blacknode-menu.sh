#!/usr/bin/env bash

options="   WiFi\n󰂯  Bluetooth\n󰓃  Audio\n󰑐  Reload\n󰃀  Bookmarks\n󰌌  Keyboard Layout\n󰎆  Music\n󰅍  Clipboard"

chosen=$(echo -e "$options" | rofi -dmenu -i -p "BlackNode..." -theme ~/.config/rofi/blacknode.rasi)

case "$chosen" in
    *WiFi*)
        kitty --class float-term -e nmtui ;;
    *Bluetooth*)
        kitty --class float-term -e bluetuith || bluetoothctl ;;
    *Audio*)
        pavucontrol || kitty --class float-term -e wireplumber ;;
    *Reload*)
        hyprctl reload && pkill waybar; waybar & ;;
    *Bookmarks*)
        rofi -show bookmarks || notify-send "Bookmarks" "No bookmarks configured" ;;
    *Keyboard*)
        hyprctl switchxkblayout all next ;;
    *Music*)
        playerctl play-pause ;;
    *Clipboard*)
        cliphist list | rofi -dmenu -theme ~/.config/rofi/blacknode.rasi | cliphist decode | wl-copy ;;
esac
# Inside ~/.config/waybar/scripts/blacknode-menu.sh
options="󰸉   Wallpapers\n   WiFi\n󰂯  Bluetooth\n󰓃  Audio\n󰑐  Reload\n󰌌  Keyboard Layout\n󰅍  Clipboard"

chosen=$(echo -e "$options" | rofi -dmenu -i -p "BlackNode..." -theme ~/.config/rofi/blacknode.rasi)

case "$chosen" in
    *Wallpapers*)
        ~/.config/hypr/scripts/wallpaper-selector.sh ;;
    # ... rest of your options
esac
