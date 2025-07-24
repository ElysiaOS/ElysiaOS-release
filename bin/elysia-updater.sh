#!/bin/bash

# Prevent multiple instances
if pgrep -f "update.py" > /dev/null; then
    echo "Elysia Updater is already running."
    exit 1
fi

# Detect real user
REAL_USER=$(logname)
REAL_HOME=$(eval echo "~$REAL_USER")

# Get GTK theme (optional)
GTK_THEME=$(sudo -u "$REAL_USER" DBUS_SESSION_BUS_ADDRESS=$(grep -z DBUS_SESSION_BUS_ADDRESS /proc/$(pgrep -u "$REAL_USER" gnome-session | head -n 1)/environ 2>/dev/null | tr '\0' '\n' | grep DBUS_SESSION_BUS_ADDRESS= | cut -d= -f2-) \
    gsettings get org.gnome.desktop.interface gtk-theme | tr -d "'")

# Allow root to access X session
xhost +SI:localuser:root

# Launch your app with proper environment
pkexec env DISPLAY=$DISPLAY XAUTHORITY=$XAUTHORITY \
    QT_QPA_PLATFORMTHEME=qt5ct \
    GTK_THEME="$GTK_THEME" \
    REAL_HOME="$REAL_HOME" \
    ~/.config/Elysia/assets/ElysiaUpdater

# Revoke access after exit
xhost -SI:localuser:root
