#!/bin/bash

setsid bash -c '

while true; do
    # Check if Waybar is running
    if ! pgrep -x "waybar" > /dev/null; then
        echo "Waybar is not running. Waiting..."
        sleep 10
        continue
    fi

    # Check for album art from prioritized players
    album_art=$(playerctl -p kew metadata mpris:artUrl 2>/dev/null || \
                playerctl -p chromium metadata mpris:artUrl 2>/dev/null || \
                playerctl -p spotify metadata mpris:artUrl 2>/dev/null)

    if [[ -n $album_art ]]; then
        # Download album art
        curl -s "${album_art}" --output "/tmp/cover.jpeg"

        # Convert to circular PNG with alpha using ImageMagick
        convert /tmp/cover.jpeg -resize 128x128^ -gravity center -extent 128x128 \
            \( +clone -threshold -1 -negate -fill white -draw "circle 64,64 64,0" \) \
            -alpha off -compose CopyOpacity -composite /tmp/cover_waybar.png

        echo "/tmp/cover_waybar.png"
    else
        echo "No active players found."
    fi

    sleep 3
done
' >/dev/null 2>&1 &
