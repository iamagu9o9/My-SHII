#!/usr/bin/env bash
ws=$(hyprctl activeworkspace 2>/dev/null | awk 'NR==1{print $3}')
if [ "$(playerctl status 2>/dev/null)" = "Playing" ]; then
    song="$(playerctl metadata artist 2>/dev/null) - $(playerctl metadata title 2>/dev/null)"
    song=$(echo "$song" | tr -d '"\\' | cut -c1-28)
    echo "{\"text\":\"♪  $song\",\"class\":\"playing\"}"
else
    echo "{\"text\":\"$ws  ·  $(date '+%I:%M %p')\",\"class\":\"time\"}"
fi
