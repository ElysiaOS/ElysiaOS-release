#!/bin/bash

# Path to brightness control
BACKLIGHT_PATH="/sys/class/backlight/amdgpu_bl1/brightness"
MAX_BRIGHTNESS=$(cat /sys/class/backlight/amdgpu_bl1/max_brightness)

# Adjust brightness
echo $1 | sudo tee $BACKLIGHT_PATH > /dev/null

# Optional: Update a visual indicator or log
