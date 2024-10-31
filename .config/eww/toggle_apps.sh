#!/bin/bash

state=$(eww get open_apps)

open_apps() {
    if [[ -z $(eww windows | grep '*apps') ]]; then
        eww open sys_side 
    fi
    eww update open_apps=true
}

close_apps() {
    if [[ -z $(eww windows | grep '*apps') ]]; then
        eww close sys_side
        eww close sys_side
        eww reload
    fi
    eww update open_apps=false

}

case $1 in
    close)
        close_apps
        exit 0;;
esac

case $state in
    true)
        close_apps;;
    false)
        open_apps;;
esac