#!/usr/bin/env bash
out="$HOME/.cache/lock-art.png"
case "$1" in
    art)
        url=$(playerctl metadata mpris:artUrl 2>/dev/null)
        if [ -n "$url" ] && [ "$url" != "$(cat "$HOME/.cache/lock-art.url" 2>/dev/null)" ]; then
            if [[ "$url" == file://* ]]; then
                src="${url#file://}"
            else
                curl -sL "$url" -o /tmp/lock-art.raw
                src=/tmp/lock-art.raw
            fi
            magick "$src" -resize 112x112^ -gravity center -extent 112x112 "$out" \
                && echo "$url" > "$HOME/.cache/lock-art.url"
        fi
        [ -f "$out" ] || magick -size 112x112 xc:'#222222' "$out"
        echo "$out"
        ;;
    title)  playerctl metadata title 2>/dev/null | cut -c1-24 ;;
    artist) playerctl metadata artist 2>/dev/null | cut -c1-24 ;;
    app)    playerctl -l 2>/dev/null | head -n 1 | sed 's/\..*//' | sed 's/./\U&/' ;;
esac
