#!/bin/bash

# Get metadata using playerctl
TITLE=$(playerctl metadata title 2>/dev/null)
ARTIST=$(playerctl metadata artist 2>/dev/null)
ALBUM=$(playerctl metadata album 2>/dev/null)
COVER_URL=$(playerctl metadata mpris:artUrl 2>/dev/null)

# Fallback check
if [[ -z "$TITLE" ]]; then
    echo "No song playing"
    exit
fi

# Save info for Hyprlock to read
echo "$TITLE" > /tmp/hyprlock_title.txt
echo "$ALBUM" > /tmp/hyprlock_album.txt

# Process cover art
COVER_PATH="/tmp/hyprlock_cover.jpg"
if [[ "$COVER_URL" =~ ^file:// ]]; then
    cp "${COVER_URL#file://}" "$COVER_PATH"
else
    curl -sL "$COVER_URL" -o "$COVER_PATH"
fi

# Optional: print a combined line (like your original)
echo "$TITLE  $ARTIST"
