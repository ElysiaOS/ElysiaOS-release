#!/bin/bash

THEME_STATE_DIR="$HOME/.config/hypr"
WAYBAR_CONFIG="$HOME/.config/waybar/config.jsonc"
WAYBAR_DARK_STYLE="$HOME/.config/waybar/Dark/style.css"
WAYBAR_DARK_CONFIG="$HOME/.config/waybar/Dark/config.jsonc"

# Function to kill all running Waybar instances
kill_waybar() {
    while pgrep -x "waybar" > /dev/null; do
        echo "Terminating existing Waybar instance..."
        pkill -x "waybar"
        sleep 0.4
    done
}

# Kill existing Waybar instances
kill_waybar

# Determine theme and launch Waybar accordingly
echo "Starting Waybar..."
if [[ -f "$THEME_STATE_DIR/Dark.txt" && ! -f "$THEME_STATE_DIR/Light.txt" ]]; then
    echo "Detected Dark theme"
    waybar -c "$WAYBAR_DARK_CONFIG" -s "$WAYBAR_DARK_STYLE" & disown
elif [[ -f "$THEME_STATE_DIR/Light.txt" && ! -f "$THEME_STATE_DIR/Dark.txt" ]]; then
    echo "Detected Light theme"
    waybar -c "$WAYBAR_CONFIG" & disown
else
    echo "⚠️ Warning: No valid theme file found or both exist. Defaulting to Light."
    waybar -c "$WAYBAR_CONFIG" & disown
fi

echo "Waybar has been reloaded."
