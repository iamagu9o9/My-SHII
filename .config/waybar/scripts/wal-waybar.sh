#!/usr/bin/env bash

# Source Pywal colors cache
if [ -f ~/.cache/wal/colors.sh ]; then
    source ~/.cache/wal/colors.sh
else
    echo "Pywal colors cache not found!"
    exit 1
fi

# Write all 16 color variables (+ bg/fg) to Waybar CSS
cat <<CSS > ~/.config/waybar/colors-waybar.css
@define-color bg ${background};
@define-color fg ${foreground};
@define-color cursor ${cursor};

@define-color c0 ${color0};
@define-color c1 ${color1};
@define-color c2 ${color2};
@define-color c3 ${color3};
@define-color c4 ${color4};
@define-color c5 ${color5};
@define-color c6 ${color6};
@define-color c7 ${color7};
@define-color c8 ${color8};
@define-color c9 ${color9};
@define-color c10 ${color10};
@define-color c11 ${color11};
@define-color c12 ${color12};
@define-color c13 ${color13};
@define-color c14 ${color14};
@define-color c15 ${color15};
CSS

# Instant refresh for Waybar
pkill -USR2 waybar
