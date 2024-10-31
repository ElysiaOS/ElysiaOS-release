#!/bin/bash

state=$(eww get open_dashboard)

open_dashboard() {
    if [[ -z $(eww windows | grep '*dashboard') ]]; then
        eww open dashboard
    fi
    eww update open_dashboard=true
}

close_dashboard() {
    if [[ -z $(eww windows | grep '*dashboard') ]]; then
        eww close dashboard
        eww close dashboard
    fi
    eww update open_dashboard=false

}

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