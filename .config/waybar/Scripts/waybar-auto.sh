#!/bin/bash

# Define a temporary file to store the state
STATE_FILE="/tmp/waybar_toggle_state"

# Check if the state file exists
if [[ -f $STATE_FILE ]]; then
    # If the file exists, toggle Waybar visibility off
    pkill -SIGUSR2 waybar
    rm $STATE_FILE
else
    # If the file doesn't exist, toggle Waybar visibility on
    pkill -SIGUSR1 waybar & album_waybar.sh
    touch $STATE_FILE
fi
