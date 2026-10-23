#!/usr/bin/env bash
status=$(playerctl status 2>/dev/null)
case "$status" in
    Playing) icon=$(printf '\uf04b') ;;
    Paused)  icon=$(printf '\uf04c') ;;
    *) echo "{\"text\":\"$(printf '\uf001')  Nothing playing\",\"class\":\"idle\"}"; exit 0 ;;
esac
song="$(playerctl metadata artist 2>/dev/null) — $(playerctl metadata title 2>/dev/null)"
song=$(echo "$song" | tr -d '"\\' | cut -c1-26)
echo "{\"text\":\"$icon  $song\",\"class\":\"$(echo "$status" | tr 'A-Z' 'a-z')\"}"
