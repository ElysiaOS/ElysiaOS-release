#!/bin/bash
PROCESS_NAME="Hyprland"

if pgrep -f "$PROCESS_NAME" > /dev/null; then
    echo '      '
else
    echo ''
fi