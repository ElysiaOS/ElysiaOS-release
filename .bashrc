#
# ~/.bashrc
#

bind 'set show-all-if-ambiguous on'
bind 'TAB:menu-complete'


# If not running interactively, don't do anything

## STARTUP
~/bin/elylogo.sh

## ALIASES
alias ls='ls --color=auto'
#CHMOD
alias chmx='chmod +x'
#search filenames
alias packages="pacman -Qi | awk '/^Name/{name=\$3} /^Installed Size/{size=\$4 \" \" \$5; print name, size}' | sort -k2 -h -r"
alias paclist='pacman -Q | grep'
alias fgr='find | grep'
alias grep='grep --color=auto'
alias targz='tar xzvf'
alias tarn='tar xvf'
alias theme='xfce4-appearance-settings'
alias py='python3'
alias pystart='python -m venv ~/myenv
source ~/myenv/bin/activate'
alias rm='rm -i'
alias image='kitty +kitten icat'
alias bday='~/Elysia/bday/bday'
alias ely='kitty +kitten icat ~/bin/elyspin.gif'


## STARSHIP SHELL
eval "$(starship init bash)"


# EXPORTS
HISTSIZE=195000000;
HISTFILESIZE=1000000000
export HISTSIZE=195000000
export PATH="$HOME/bin:$PATH"
export PATH="$HOME/Pictures:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export WINEPREFIX=~/HSR-prefix # REVERSE1999 PREFIX

## COMPLETETION
_autocomplete() {
    local word="${COMP_WORDS[COMP_CWORD]}"
    
    # Combine file, directory, and command suggestions
    local suggestions=$(compgen -f -- "$word"; compgen -c -- "$word")
    
    if [ -n "$suggestions" ]; then
        echo -e "\nSuggestions:"
        local index=1
        while read -r suggestion; do
            # Display each suggestion with a number
            echo "[$index] $suggestion"
            ((index++))
        done <<< "$suggestions"
    fi
}

bind 'TAB:menu-complete'
complete -o bashdefault -o default -F _autocomplete .
