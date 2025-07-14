#!/bin/bash

state=$(eww get open_wallpaper)

open_wallpaper() {
    if [[ -z $(eww windows | grep '*wallpaper') ]]; then
        eww open wallpaper
    fi
    eww update open_wallpaper=true
}

close_wallpaper() {
    if [[ -z $(eww windows | grep '*wallpaper') ]]; then
        eww close wallpaper
        eww close wallpaper
    fi
    eww update open_wallpaper=false

}

case $1 in
    close)
        close_wallpaper
        exit 0;;
esac

case $state in
    true)
        close_wallpaper;;
    false)
        open_wallpaper;;
esac