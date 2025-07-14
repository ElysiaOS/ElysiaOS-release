#!/bin/bash

# Packages to check for updates
PACKAGES=("linux-zen" "linux-cachyos" "hyprland", "linux")

# File to store previously notified updates
STATE_FILE="$HOME/.config/.checkupdates_notified"

# Ensure the state file exists
touch "$STATE_FILE"

# Get updates using checkupdates
UPDATES=$(checkupdates 2>/dev/null)

# Filter updates for the specified packages
FOUND_UPDATES=$(echo "$UPDATES" | grep -E "^($(IFS=\|; echo "${PACKAGES[*]}"))")

# Initialize an array to store new notifications
NEW_NOTIFICATIONS=()

# Process each update
while read -r UPDATE; do
    if [[ -n "$UPDATE" ]]; then
        PACKAGE=$(echo "$UPDATE" | awk '{print $1}')
        VERSION=$(echo "$UPDATE" | awk '{print $2}')
        STATE="$PACKAGE $VERSION"

        # Check if this update has already been notified
        if ! grep -Fxq "$STATE" "$STATE_FILE"; then
            # Add to new notifications
            NEW_NOTIFICATIONS+=("$STATE")
            # Append to the state file
            echo "$STATE" >> "$STATE_FILE"
        fi
    fi
done <<< "$FOUND_UPDATES"

# If there are new updates, notify the user
if [[ ${#NEW_NOTIFICATIONS[@]} -gt 0 ]]; then
    # Format notification
    NOTIFICATION="Updates available:\n$(printf "%s\n" "${NEW_NOTIFICATIONS[@]}")"
    echo -e "$NOTIFICATION"

    # Send desktop notification
    notify-send "Package Updates" "$NOTIFICATION" --icon=preferences-desktop-display
else
    echo "No new updates for specified packages."
fi
