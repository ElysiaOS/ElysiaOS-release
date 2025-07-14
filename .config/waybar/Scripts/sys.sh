#!/bin/bash

# Check if Hyprland is running
if pgrep -f "Hyprland" > /dev/null; then
    HYPR="ElysiaOS"
else
    HYPR="ElysiaOS"
fi

# Check Wi-Fi status and SSID
WIFI_STATUS=$(nmcli -t -f WIFI g)
if [[ "$WIFI_STATUS" == "enabled" ]]; then
    WIFI_STATE=$(nmcli -t -f STATE g)
    if [[ "$WIFI_STATE" == "connected" ]]; then
        SSID=$(nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d: -f2)
        WIFI="Wi-Fi: connected ($SSID)"
    else
        WIFI="Wi-Fi: enabled (no connection)"
    fi
else
    WIFI="Wi-Fi: disabled"
fi

# Check Bluetooth status and connected device names
if bluetoothctl show | grep -q "Powered: yes"; then
    BT_DEVICES=$(bluetoothctl info | grep 'Name:' | awk -F': ' '{print $2}')
    if [[ -n "$BT_DEVICES" ]]; then
        BT="Bluetooth: on ($BT_DEVICES)"
    else
        BT="Bluetooth: on"
    fi
else
    BT="Bluetooth: off"
fi

# Combine tooltip
TOOLTIP="$HYPR\n$WIFI\n$BT"

# Add invisible padding to widen icon space
echo "{\"text\": \"      \", \"tooltip\": \"$TOOLTIP\"}"
