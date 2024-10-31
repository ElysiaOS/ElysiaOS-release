#!/bin/bash

# Take a screenshot of the selected region and save it with a timestamp
screenshot="$HOME/Pictures/Screenshots/$(date '+%y%m%d_%H-%M-%S').png"
grim -g "$(slurp)" "$screenshot" && wl-copy < "$screenshot"

# Send a notification with the screenshot name and a "Copy" button
notify-send "Screenshot taken" "$screenshot" --action=copy:"Copy"

# Wait for the "Copy" action to be triggered
gdbus call --session --dest org.freedesktop.Notifications --object-path /org/freedesktop/Notifications --method org.freedesktop.Notifications.GetCapabilities | grep -q "actions"

# After "Copy" button is clicked, copy the screenshot to the clipboard again
wl-copy < "$screenshot"
notify-send "Screenshot copied to clipboard" "Elysia says thank you"
