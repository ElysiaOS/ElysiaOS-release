#!/bin/bash

# Prevent multiple instances
if pgrep -f "update.py" > /dev/null; then
    echo "Elysia Updater is already running."
    exit 1
fi

# Detect real user
REAL_USER=$(logname)

# Get GTK theme (only if needed)
GTK_THEME=$(sudo -u "$REAL_USER" DBUS_SESSION_BUS_ADDRESS=$(grep -z DBUS_SESSION_BUS_ADDRESS /proc/$(pgrep -u "$REAL_USER" gnome-session | head -n 1)/environ 2>/dev/null | tr '\0' '\n' | grep DBUS_SESSION_BUS_ADDRESS= | cut -d= -f2-) \
    gsettings get org.gnome.desktop.interface gtk-theme | tr -d "'")

# Allow root to access your X session temporarily
xhost +SI:localuser:root

# Launch your app with GTK_THEME passed in
pkexec env DISPLAY=$DISPLAY XAUTHORITY=$XAUTHORITY \
    QT_QPA_PLATFORMTHEME=qt5ct \
    GTK_THEME="$GTK_THEME" \
    /usr/bin/python3 ~/Elysia/assets/update.py

# Remove access after it exits
xhost -SI:localuser:root
