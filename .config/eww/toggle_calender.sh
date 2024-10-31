#!/bin/bash

state=$(eww get open_musicbox)

open_musicbox() {
    if [[ -z $(eww windows | grep '*musicbox') ]]; then
        eww open calender 
    fi
    eww update open_musicbox=true
}

close_musicbox() {
    if [[ -z $(eww windows | grep '*musicbox') ]]; then
        eww close calender 
    fi
    eww update open_musicbox=false

}

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