#!/bin/bash

LANGS_FILE="$(dirname "$0")/langs.json"
LAYOUT_FILE="/tmp/current_layout"

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    notify-send "Elysia" "Missing dependency: jq"
    exit 1
fi

# Ensure langs.json exists
if [[ ! -f "$LANGS_FILE" ]]; then
    notify-send "Elysia" "langs.json not found!"
    exit 1
fi

# Read JSON array into a bash array
readarray -t LAYOUTS < <(jq -r '.[]' "$LANGS_FILE")

# Exit if no layouts found
if [[ ${#LAYOUTS[@]} -eq 0 ]]; then
    notify-send "Elysia" "No layouts found in langs.json"
    exit 1
fi

# Initialize layout file if not exists
if [[ ! -f "$LAYOUT_FILE" ]]; then
    echo "${LAYOUTS[0]}" > "$LAYOUT_FILE"
fi

CURRENT=$(cat "$LAYOUT_FILE")

# Find index of current layout
CURRENT_INDEX=-1
for i in "${!LAYOUTS[@]}"; do
    if [[ "${LAYOUTS[$i]}" == "$CURRENT" ]]; then
        CURRENT_INDEX=$i
        break
    fi
done

# If current not found, default to first
if [[ $CURRENT_INDEX -eq -1 ]]; then
    NEXT_LAYOUT="${LAYOUTS[0]}"
else
    NEXT_INDEX=$(( (CURRENT_INDEX + 1) % ${#LAYOUTS[@]} ))
    NEXT_LAYOUT="${LAYOUTS[$NEXT_INDEX]}"
fi

# Apply and store new layout
hyprctl keyword input:kb_layout "$NEXT_LAYOUT"
echo "$NEXT_LAYOUT" > "$LAYOUT_FILE"

# Notify with layout code (dynamic)
notify-send --icon=preferences-desktop-display "Elysia" "Keyboard layout changed to $NEXT_LAYOUT"
