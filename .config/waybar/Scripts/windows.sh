#!/bin/bash

# Path to the style.css file
STYLE_CSS="/home/matsuko/.config/waybar/style.css"

# Path to the icons directory
ICON_DIR="/home/matsuko/.icons/ElysiaOS/128/apps"

# Function to update the background-image for #custom-game-icon in style.css
update_icon() {
    local icon_path="$1"
    # Use sed to specifically match and update the background-image for #custom-game-icon only
    sed -i "/#custom-game-icon {/ , /}/s|background-image: url('.*');|background-image: url('$icon_path');|" "$STYLE_CSS"
}

# Function to get the icon for an app
get_app_icon() {
    local window_class="$1"
    
    # Check if the app class is a known one and set the icon accordingly
    case "$window_class" in
        "com.moonlight_stream.Moonlight")
            echo "$ICON_DIR/moonlight.png"  # Moonlight icon
            ;;
        "zen-browser")
            # For Zen Browser, we look for the .desktop file in the applications directory
            desktop_file=$(find ~/.local/share/applications/ -iname "*zen*.desktop" | head -n 1)
            if [ -f "$desktop_file" ]; then
                # Extract the icon field from the .desktop file
                icon=$(grep -i "^Icon=" "$desktop_file" | cut -d '=' -f2)
                if [ -f "/home/matsuko/.local/share/icons$icon" ]; then
                    echo "/home/matsuko/.local/share/icons$icon"
                else
                    echo "$ICON_DIR/default.png"  # Default icon if no specific icon found
                fi
            else
                echo "$ICON_DIR/default.png"  # Default icon if no .desktop file found
            fi
            ;;
        *)
            echo "$ICON_DIR/default.png"  # Default icon if the class is unknown
            ;;
    esac
}

# Loop to continuously check and update the icon every 2 seconds
while true; do
    # Get the active window class using hyprctl
    active_window_json=$(hyprctl activewindow -j)
    window_class=$(echo "$active_window_json" | jq -r '.class')

    # Debugging: Print the window class
    echo "Active window class: $window_class"

    # Get the icon based on the window class
    icon_path=$(get_app_icon "$window_class")

    # Update the icon in the style.css
    update_icon "$icon_path"

    # Wait for 2 seconds before checking again
    sleep 2
done
