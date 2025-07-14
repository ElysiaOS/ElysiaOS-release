
#!/bin/bash

state=$(eww get open_musicbox)

if [[ -f ~/.config/hypr/Dark.txt ]]; then
    open_musicbox() {
        if [[ -z $(eww active-windows | grep '*calender') ]]; then
            eww -c ~/.config/eww/Dark/ open calender
        fi
        eww update open_musicbox=true
    }

    close_musicbox() {
        eww -c ~/.config/eww/Dark/ close calender
        sleep 0.3

        calender_pids=$(pgrep -f "eww.*calender" | wc -l)
        if (( calender_pids > 1 )); then
            echo "Detected $calender_pids calender-related eww processes — restarting eww..."
        fi

        eww update open_musicbox=false
    }

elif [[ -f ~/.config/hypr/Light.txt ]]; then
    open_musicbox() {
        if [[ -z $(eww active-windows | grep '*calender') ]]; then
            eww open calender
        fi
        eww update open_musicbox=true
    }

    close_musicbox() {
        eww close calender
        sleep 0.3

        calender_pids=$(pgrep -f "eww.*calender" | wc -l)
        if (( calender_pids > 1 )); then
            echo "Detected $calender_pids calender-related eww processes — restarting eww..."
            pkill eww
            eww daemon
        fi

        eww update open_musicbox=false
    }

else
    # Default to Light if neither file exists
    open_musicbox() {
        if [[ -z $(eww active-windows | grep '*calender') ]]; then
            eww open calender
        fi
        eww update open_musicbox=true
    }

    close_musicbox() {
        eww close calender

        calender_pids=$(pgrep -f "eww.*calender" | wc -l)
        if (( calender_pids > 1 )); then
            echo "Detected $calender_pids calender-related eww processes — restarting eww..."
        fi

        eww update open_musicbox=false
    }
fi

case $1 in
    close)
        close_musicbox
        exit 0;;
esac

case $state in
    true)
        close_musicbox;;
    false)
        open_musicbox;;
esac
