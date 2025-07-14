
#!/bin/bash

state=$(eww get open_musicbox2)

if [[ -f ~/.config/hypr/Dark.txt ]]; then
    open_musicbox2() {
        if [[ -z $(eww active-windows | grep '*musicbox') ]]; then
            eww -c ~/.config/eww/Dark/ open musicbox
        fi
        eww update open_musicbox2=true
    }

    close_musicbox2() {
        eww -c ~/.config/eww/Dark/ close musicbox
        sleep 0.3

        musicbox_pids=$(pgrep -f "eww.*musicbox" | wc -l)
        if (( musicbox_pids > 1 )); then
            echo "Detected $musicbox_pids musicbox-related eww processes — restarting eww..."
        fi

        eww update open_musicbox2=false
    }

elif [[ -f ~/.config/hypr/Light.txt ]]; then
    open_musicbox2() {
        if [[ -z $(eww active-windows | grep '*musicbox') ]]; then
            eww open musicbox
        fi
        eww update open_musicbox2=true
    }

    close_musicbox2() {
        eww close musicbox
        sleep 0.3

        musicbox_pids=$(pgrep -f "eww.*musicbox" | wc -l)
        if (( musicbox_pids > 1 )); then
            echo "Detected $musicbox_pids musicbox-related eww processes — restarting eww..."
            pkill eww
            eww daemon
        fi

        eww update open_musicbox2=false
    }

else
    # Default to Light if neither file exists
    open_musicbox2() {
        if [[ -z $(eww active-windows | grep '*musicbox') ]]; then
            eww open musicbox
        fi
        eww update open_musicbox2=true
    }

    close_musicbox2() {
        eww close musicbox

        musicbox_pids=$(pgrep -f "eww.*musicbox" | wc -l)
        if (( musicbox_pids > 1 )); then
            echo "Detected $musicbox_pids musicbox-related eww processes — restarting eww..."
        fi

        eww update open_musicbox2=false
    }
fi

case $1 in
    close)
        close_musicbox2
        exit 0;;
esac

case $state in
    true)
        close_musicbox2;;
    false)
        open_musicbox2;;
esac
