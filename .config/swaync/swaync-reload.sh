#!/bin/bash

THEME_STATE_DIR="$HOME/.config/hypr"
swaync_DARK_STYLE="$HOME/.config/swaync/Dark/style.css"

# Function to kill all running swaync instances
kill_swaync() {
    while pgrep -x "swaync" > /dev/null; do
        echo "Terminating existing swaync instance..."
        pkill -x "swaync"
        sleep 0.4
    done
}

# Kill existing swaync instances
kill_swaync

# Determine theme and launch swaync accordingly
echo "Starting swaync..."
if [[ -f "$THEME_STATE_DIR/Dark.txt" && ! -f "$THEME_STATE_DIR/Light.txt" ]]; then
    echo "Detected Dark theme"
    swaync -s "$swaync_DARK_STYLE" & disown
elif [[ -f "$THEME_STATE_DIR/Light.txt" && ! -f "$THEME_STATE_DIR/Dark.txt" ]]; then
    echo "Detected Light theme"
    swaync & disown
else
    echo "⚠️ Warning: No valid theme file found or both exist. Defaulting to Light."
    swaync & disown
fi

echo "swaync has been reloaded."
