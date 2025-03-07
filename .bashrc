[ "${PX[log]}" ] && echo ".bashrc"

type shopt &>/dev/null && if [[ $? ]]; then
    # check window size after each command and update values of LINES and COLUMNS
    shopt -s checkwinsize
    # append to the history file, don't overwrite
    shopt -s histappend
fi

export BASHRC="true"
# args=(BASHRC "${PX[color]}")
[ "$1" != "LOGIN" -a -f "${HOME}/.profile" ] && \
    builtin source "${HOME}/.profile" BASHRC $PX_color $PWD


# avoid duplicate or empty (whitespaces) lines in history
# https://www.baeldung.com/linux/history-remove-avoid-duplicates
export HISTCONTROL=ignoreboth:erasedups
export HISTSIZE=999
export HISTFILESIZE=999

alias c="clear"
alias aliases="alias"
alias vi="vim"                  # use vim for vi, -u ~/.vimrc
alias ls="/bin/ls \$LS_COLOR"   # colorize ls output
alias l="ls -alFog"             # detailed list with dotfiles
alias ll="ls -l"                # detailed list with no dotfiles
alias grep="grep \$LS_COLOR"
alias egrep="egrep \$LS_COLOR"
alias pwd="pwd -LP"             # show real path with resolved links
alias path="tr ':' '\n' <<< \$PATH"

# set up git aliases, if git is installed
[ "${PX[has-git]}" ] && \
    alias gt="git status" && \
    alias log="git log --oneline" && \
    alias br="git branch -avv" && \
    alias switch="git switch" && \
    alias prune="git reflog expire --expire=now --all; git gc --prune=now --aggressive" && \
    alias gar="[ -d .git ] && tar cvf \$(date '+%y-%m%d-git.tar') .git || echo 'no .git directory'" && \
    alias gls="git show --name-status"
