#!/bin/bash

state=$(eww get open_dashboard)

if [[ -f ~/.config/hypr/Dark.txt ]]; then
    open_dashboard() {
        if [[ -z $(eww active-windows | grep '*dashboard') ]]; then
            eww -c ~/.config/eww/Dark/ open dashboard
        fi
        eww update open_dashboard=true
    }

    close_dashboard() {
        eww -c ~/.config/eww/Dark/ close dashboard
        sleep 0.3

        dashboard_pids=$(pgrep -f "eww.*dashboard" | wc -l)
        if (( dashboard_pids > 1 )); then
            echo "Detected $dashboard_pids dashboard-related eww processes — restarting eww..."
            pkill eww
            sleep 0.3
            eww daemon
        fi

        eww update open_dashboard=false
    }

elif [[ -f ~/.config/hypr/Light.txt ]]; then
    open_dashboard() {
        if [[ -z $(eww active-windows | grep '*dashboard') ]]; then
            eww open dashboard
        fi
        eww update open_dashboard=true
    }

    close_dashboard() {
        eww close dashboard
        sleep 0.3

        dashboard_pids=$(pgrep -f "eww.*dashboard" | wc -l)
        if (( dashboard_pids > 1 )); then
            echo "Detected $dashboard_pids dashboard-related eww processes — restarting eww..."
            pkill eww
            sleep 0.3
            eww daemon
        fi

        eww update open_dashboard=false
    }

else
    # Default to Light if neither file exists
    open_dashboard() {
        if [[ -z $(eww active-windows | grep '*dashboard') ]]; then
            eww open dashboard
        fi
        eww update open_dashboard=true
    }

    close_dashboard() {
        eww close dashboard
        sleep 0.3

        dashboard_pids=$(pgrep -f "eww.*dashboard" | wc -l)
        if (( dashboard_pids > 1 )); then
            echo "Detected $dashboard_pids dashboard-related eww processes — restarting eww..."
            pkill eww
            sleep 0.3
            eww daemon
        fi

        eww update open_dashboard=false
    }
fi

case $1 in
    close)
        close_dashboard
        exit 0;;
esac

case $state in
    true)
        close_dashboard;;
    false)
        open_dashboard;;
esac
