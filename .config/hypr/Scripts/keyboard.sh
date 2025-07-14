#!/bin/bash


icon_path="$HOME/.config/waybar/icons/22.png"

LAYOUT_FILE="/tmp/current_layout"

if [[ ! -f "$LAYOUT_FILE" ]]; then
    echo "us" > "$LAYOUT_FILE"
fi

CURRENT=$(cat "$LAYOUT_FILE")

if [[ "$CURRENT" == "us" ]]; then
    hyprctl keyword input:kb_layout ara
    echo "ara" > "$LAYOUT_FILE"
    notify-send -i "$icon_path" "Elysia" "Keyboard layout changed to Arabic"
else
    hyprctl keyword input:kb_layout us
    echo "us" > "$LAYOUT_FILE"
    notify-send -i "$icon_path" "Elysia" "Keyboard layout changed to English"
fi
