#!/bin/bash

# Detach the script from any controlling terminal and prevent signal inheritance
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
        # If an album art URL is found, download it
        curl -s "${album_art}" --output "/tmp/cover.jpeg"
        echo "/tmp/cover.jpeg"
    else
        # No active player, continue to wait
        echo "No active players found."
    fi

    # Pause before checking again
    sleep 3
done
' >/dev/null 2>&1 &
