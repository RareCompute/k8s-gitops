#!/bin/bash
alias c="clear"
alias cc="clear && cd"
alias k="kubectl"
alias l="ls -laht"
alias s="sudo"

# credit: https://superuser.com/a/39995
path_add() {
    if [ -d "$1" ] && [[ ":$PATH:" != *":$1:"* ]]; then
        PATH="${PATH:+"$PATH:"}$1"
    fi
}
