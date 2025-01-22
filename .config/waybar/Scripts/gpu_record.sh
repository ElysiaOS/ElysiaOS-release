#!/bin/bash
PROCESS_NAME="gpu-screen-recorder"

if pgrep -f "$PROCESS_NAME" > /dev/null; then
    echo '●'
else
    echo ''
fi