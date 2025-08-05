# .bashrc is executed when a new bash process is started.

if [[ "$SHELL" =~ bash && "$PX_EXPORT" ]]; then
    # import PX associative array into child-shell from the 'PX_EXPORT' variable, see brilliant advice at
    # https://stackoverflow.com/questions/65341786/shell-script-pass-associative-array-to-another-shell-script
    # 
    # import PX associative array from PX_EXPORT in sub-shell to inherit properties
    # 
    declare -A PX="${PX_EXPORT#*=}"
fi

[ "${PX[log]}" ] && echo -n " -> .bashrc"

type shopt &>/dev/null && if [[ $? ]]; then
    # check window size after each command and update values of LINES and COLUMNS
    shopt -s checkwinsize
    # append to the history file, don't overwrite
    shopt -s histappend
fi

function setup_bash() {
    # 
    [ -z "${PX[has-color]}" ] && \
        local colors=$(tput colors) && \
        [[ "$colors" -gt 1 ]] && PX[has-color]="true"
    # 
    # declare functions defined in platform-specific .bashrc extension file, e.g. '.bashrc-win-x1'
    [ -f "${HOME}/${PX[bashrc-ext]}" ] && \
        builtin source "${HOME}/${PX[bashrc-ext]}" "$1"
    # 
    [ "${PX[log]}" ] && echo
    # 
    if [ "${PX[color]}" ]; then
        # sets PS1 in sub-shell
        color "${PX[color]}"    # set color 'on' or 'off'
    else
        [ "${PX[has-color]}" = true ] && color on || color off
    fi
    # 
    # export PX associative array via 'PX_EXPORT' variable to pass to child-shell, brilliant advice from
    # https://stackoverflow.com/questions/65341786/shell-script-pass-associative-array-to-another-shell-script
    [ -z "$PX_EXPORT" ] && \
        export PX_EXPORT="$(declare -p PX)"
    # 
    local px_file="${HOME}/${PX[bashrc-px]}"
    if [[ "$SHELL" =~ bash && ! -f "$px_file" ]]; then
        echo "$PX_EXPORT" > "$px_file"
    fi
    # 
    trap "echo -ne '\e[m'" DEBUG    # reset formatting after command + ENTER
    return 0
}

function color() {
    local prev_col="${PX[color]}"
    [ -z "$*" ] && \
        echo "color is ${PX[color]}"
    # 
    for arg in $*; do
        # 
        if [ "$arg" = "on" -a "$prev_col" != "$arg" -a "${PX[has-color]}" ]; then
            PX[color]="on"
            export TERM="${PX[term]}"       # re-enable color terminal
            export LS_COLOR="--color=auto"
            [ "${PX[git-project-name]}" ] && \
                export PS1="${PX[ps1-git-color]}" || export PS1="${PX[ps1-color]}"
            # 
            trap "echo -ne '\e[m'" DEBUG    # reset formatting after command + ENTER
        fi
        if [ "$arg" = "off" -a "$prev_col" != "$arg" ]; then
            trap "" DEBUG    # disable ANSI escape caracters after command + ENTER
            PX[color]="off"
            export TERM="dumb"              # monochrome terminal git responds to
            export PS1="${PX[ps1-mono]}"
            export LS_COLOR="--color=none"  # alt: "never"
            [ "${PX[git-project-name]}" ] && \
                export PS1="${PX[ps1-git-mono]}" || export PS1="${PX[ps1-mono]}"
        fi
    done
    # re-export PX array if 'PX[color]' changed
    [ "${PX[color]}" != "$prev_col" ] && \
        export PX_EXPORT="$(declare -p PX)"
}

# variables used in PS1 prompt to show path $PWD relative to $PRHOME (project HOME)
PRHOME=$HOME

# probe for git and overload 'cd' for using git-prompt in git project
[ "${PX[has-git]}" ] && \
    \
    function cd() {
        [ -z "$1" ] && cd "$PRHOME" && return 0
        [ "$1" = "..." ] && cd "$HOME" && return 0
        [ -L "$1" ] && local is_link="true"
        [ ! -d "$1" ] && echo "cd $1: no such file or directory" && return 0 || \
            builtin cd "$1"
        # 
        [ "$is_link" ] && \
            export PWD=$(pwd) && \
            [[ "$SHELL" =~ zsh ]] && PWD="/"${PWD#*/}
            # for zsh, remove ANSI reset "\e[0m" front of 'PWD' variable from $(pwd) execution
        # 
        # attempt to locate git project traversing upwards in directory tree
        local p="$PWD"
        while [[ ${#p} -gt 3 ]]; do
            [ -d "$p/.git" -a "$p" != "$HOME" -a "$p" != "/c/Sven1/svgr2" ] && \
                local proj_abs="$p" && break
            p=${p%/*}   # remove last part of path, same as: p=$(dirname "$p")
        done
        # 
        if [ "$proj_abs" ]; then
            if [ ! "$PRHOME" = "$proj_abs" ]; then
                PX[git-project-name]="${proj_abs//*\//}"    #  use last part of $proj_abs
                PRHOME="$proj_abs"
                [ "${PX[color]}" = "on" ] && \
                    export PS1="${PX[ps1-git-color]}" || export PS1="${PX[ps1-git-mono]}"
            fi
        else
            PRHOME="$HOME"; PX[git-project-name]=""
            [ "${PX[color]}" = "on" ] && \
                export PS1="${PX[ps1-color]}" || export PS1="${PX[ps1-mono]}"
        fi
        return 0
    }

alias c="clear"                 # clear terminal
alias aliases="alias"           # show aliases
alias vi="vim"                  # use 'vim' for 'vi', -u ~/.vimrc
alias ls="ls \$LS_COLOR"        # colorize ls output
alias l="ls -alFog"             # detailed list with dotfiles
alias ll="ls -l"                # detailed list with no dotfiles
alias grep="grep \$LS_COLOR"    # enable colored output for grep command
alias egrep="egrep \$LS_COLOR"  # enable colored output for egrep command
alias pwd="pwd -LP"             # show real path with resolved links
alias path="tr ':' '\n' <<< \$PATH"         # pretty print PATH
                                # show environment variables, except prompt strings,
alias env="/usr/bin/env | grep -v '\['"     # e.g. PS1, PX_EXPORT
alias vscode="code"             # launch VSCode with command 'code'
# 
[ "$MAVEN_HOME" ] && \
    alias mvn="$MAVEN_HOME/bin/mvn $mvn_mono"   # -B: color off

function h() {          # list history commands, select by $1
    [ "$1" == "--all" ] && history | uniq -f 1 && return
    [ "$1" ] && history | grep $1 | uniq -f 1 || history | tail -40
}

function functions() {  # list functions by name or specific function
    local fname="$1"
    [ "$fname" ] && typeset -f $fname || declare -F
}

function crlf() {   # list text files with CR/LF (Windows) line endings
    [ "$1" ] && local dir="$*" || local dir="."
    find "$dir" -not -type d -exec file "{}" ";" | grep CRLF # | cut -d: -f1
}

# function cr2lf() {  # replace CR/LF (Windows) with newline (Unix) line endings
#     for f in $(crlf "$*"); do
#         echo "-- converting CRLF to '\n' in --> $f"
#         tmpfile="/tmp/$(basename "$f")"
#         sed 's/\r$//' < "$f" > "$tmpfile"
#         mv "$tmpfile" "$f"
#     done
# }

# set up git aliases, if git is installed
[ "${PX[has-git]}" ] && \
    alias gt="git status" && \
    alias switch="git switch" && \
    alias log="git log --oneline" && \
    alias br="git branch -avv" && \
    alias prune="git reflog expire --expire=now --all; git gc --prune=now --aggressive" && \
    alias gar="[ -d .git ] && tar cvf \$(date '+%y-%m%d-git.tar') .git || echo 'no .git directory'" && \
    \
    function merge() {
        local sopt="\\\\\n\t\t--strategy-option"
        local args=()
        # 
        for arg in $@; do case "$arg" in
        --pull|--fetch) [ "$arg" == "--fetch" ] && local fetch=true ;;
        --theirs|--ours) [ "$arg" == "--ours" ] && local ourthrs="$sopt ours" || local ourthrs="$sopt theirs" ;;
        --show) local show=true ;;
        *) args+=($arg) ;;
        esac done
        for arg in ${args[@]}; do
            [ "$branch" ] && local remote="$branch" && local branch="$arg" || local branch="$arg"
        done
        if [ "$remote" ]; then
            [ "$fetch" ] && \
                local cmd="git fetch $remote $branch\ngit merge $remote/$branch --squash --allow-unrelated-histories $ourthrs" || \
                local cmd="git pull  $remote $branch --squash --allow-unrelated-histories $ourthrs"
        else
            if [ "$branch" ]; then
                local cmd="git merge $branch --squash"
            else
                echo -e "merge <remote> <branch> [--show|--pull (default)|--fetch|--ours|--theirs]\n";
                merge --show --fetch "<remote>" "<branch>"; echo;
                merge --show "<remote>" "<branch>"
            fi
        fi
        [ "$show" ] && echo -e $cmd
    }

# source .env file if found in project directory or else source ~/.bashrc
function source() {
    [ "$1" ] && builtin source "$1" \
        || \
        for env_dir in . .env env ~; do
            for env_file in .env.sh env.sh .bashrc; do
                [ -f "$env_dir/$env_file" ] && \
                    builtin source "$env_dir/$env_file" && \
                    echo "sourced: $env_dir/$env_file" && \
                    return
            done
        done
}


# run bash setup script, 'cd .' needed to set prompt in sub-shell
setup_bash "$1" && \
    cd . && \
    unset -f setup_bash
