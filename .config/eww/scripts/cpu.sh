#!/usr/bin/env bash
# Save this script as ~/.config/eww/scripts/cpu_usage.sh
top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}' # Get CPU usage
