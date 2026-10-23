#!/usr/bin/env bash
lock=$'\uf023'
logout=$'\uf2f5'
suspend=$'\uf186'
reboot=$'\uf021'
power=$'\uf011'

chosen=$(printf '%s\n%s\n%s\n%s\n%s\n' "$lock" "$logout" "$suspend" "$reboot" "$power" \
    | rofi -dmenu -theme ~/.config/rofi/power.rasi -p "")

case "$chosen" in
    "$lock")    hyprlock ;;
    "$logout")  loginctl terminate-user "$USER" ;;
    "$suspend") systemctl suspend ;;
    "$reboot")  systemctl reboot ;;
    "$power")   systemctl poweroff ;;
esac
