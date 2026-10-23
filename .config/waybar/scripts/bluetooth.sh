#!/usr/bin/env bash
THEME=~/.config/rofi/menu.rasi

if [ "$(bluetoothctl show | awk '/Powered:/ {print $2}')" = "yes" ]; then
    toggle="󰂲  Turn Bluetooth off"
else
    toggle="󰂯  Turn Bluetooth on"
fi

declare -A map
entries="$toggle\n  Pair new device\n"

while read -r _ mac name; do
    [ -z "$mac" ] && continue
    if bluetoothctl info "$mac" | grep -q "Connected: yes"; then
        label="●  $name"
    else
        label="○  $name"
    fi
    map["$label"]=$mac
    entries+="$label\n"
done < <(bluetoothctl devices)

chosen=$(printf "%b" "$entries" | rofi -dmenu -i -p "Bluetooth" -theme "$THEME")
[ -z "$chosen" ] && exit 0

case "$chosen" in
    *"Turn Bluetooth off") bluetoothctl power off ;;
    *"Turn Bluetooth on")  rfkill unblock bluetooth; bluetoothctl power on ;;
    *"Pair new device")    blueman-manager ;;
    *)
        mac="${map[$chosen]}"
        [ -z "$mac" ] && exit 0
        if bluetoothctl info "$mac" | grep -q "Connected: yes"; then
            bluetoothctl disconnect "$mac" && notify-send "Bluetooth" "Disconnected"
        else
            bluetoothctl connect "$mac" && notify-send "Bluetooth" "Connected"
        fi
        ;;
esac
