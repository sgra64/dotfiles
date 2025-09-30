#!/bin/bash
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# .bashrc is executed when every new bash process (sub-process).
# \\
# This file .bashrc creates the basic environment. It sources file .bashrc.paths
# to create additions depending on installed applications.
# \\
# The overall environment is comprised of:
# 
# - environment variables:
#    - USER, HOME, PATH, HOSTNAME, LANG, LS_COLOR, LS_COLORS, TERM
#    - JAVA_HOME, MAVEN_HOME, M2_HOME, PYTHON_HOME, DOCKER_HOME
# 
# - aliases:
#    - l, ll, aliases (show aliases), env (show env), path (show path),
#    - gt (git status), br (git branch -avv), log (git log --oneline),
#      switch (git switch <branch>)
# 
# - useful functions:
#    - chrome (launch chrome web-browser), sublime (launch sublime editor)
#    - code (launch VSCode IDE in current directory), eclipse (launch eclipse)
#    - functions (show functions), h (show history)
#    - cd (overloaded 'cd' command to change prompt when entering git projects)
#    - source (overloaded 'source' command to auto-locate sourceable files)
#    - color on|off (toggle terminal color on|off)
#    - crlf (find text files with CR/LF line-ending)
# \\
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

if [[ "$PX_EXPORT" && "$SHELL" =~ bash ]]; then
    # Re-store PX[] array in sub-process from the 'PX_EXPORT' variable.
    # Associative arrays are not passed to child processes, see
    # https://stackoverflow.com/questions/65341786/shell-script-pass-associative-array-to-another-shell-script
    # 
    declare -A PX="${PX_EXPORT#*=}"
fi

[ "${PX[log]}" ] && echo -n " -> .bashrc"       # log, if enabled

type shopt &>/dev/null && if [[ $? ]]; then
    # test window size after each command and update values LINES and COLUMNS
    shopt -s checkwinsize
    # append to the history file, don't overwrite
    shopt -s histappend
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# bash_rc() function
#  - source '$HOME/${PX[bashrc-ext]}' file, if present, re-initialize colors
#  - store PX[] associative array in 'PX_EXPORT' variable to pass to sub-shell
# \\
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function bash_rc() {
    # 
    [ -z "${PX[has-color]}" ] && \
        local colors=$(tput colors) && \
        [[ "$colors" -gt 1 ]] && PX[has-color]="true"
    # 
    # declare functions defined in platform-specific .bashrc extension file, e.g. '.bashrc-win-x1'
    [ -f "$HOME/${PX[bashrc-ext]}" ] && \
        builtin source "$HOME/${PX[bashrc-ext]}" "$1"
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
    # store PX[] associative array in 'PX_EXPORT' variable to pass to sub-shell
    [ -z "$PX_EXPORT" ] && \
        export PX_EXPORT="$(declare -p PX)"
    # 
    local px_file="${HOME}/${PX[bashrc-px]}"
    if [[ "$SHELL" =~ bash && ! -f "$px_file" ]]; then
        echo "$PX_EXPORT" > "$px_file"
    fi
    # 
    return 0
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# color() function to toggle colors 'on' and 'off'
# Usage:
#  - color on | color off
# \\
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function color() {
    local prev_col="${PX[color]}"
    [ -z "$*" ] && echo "color is ${PX[color]}"
    # 
    for arg in $*; do
        # 
        if [ "$arg" = "on" -a "$prev_col" != "$arg" -a "${PX[has-color]}" ]; then
            PX[color]="on"
            export TERM="${PX[term]}"           # re-enable color terminal
            export LS_COLOR="--color=auto"
            [ "${PX[git-project-name]}" ] &&
                export PS1="${PX[ps1-git-color]}" || export PS1="${PX[ps1-color]}"
            # 
            [[ ! "$SHELL" =~ zsh ]] &&
                trap "echo -ne '\e[m'" DEBUG    # reset color in typed line after command+ENTER
        fi
        if [ "$arg" = "off" -a "$prev_col" != "$arg" ]; then
            [[ ! "$SHELL" =~ zsh ]] &&
                trap "" DEBUG       # disable ANSI escape caracters after command + ENTER
            PX[color]="off"
            export TERM="dumb"                  # monochrome terminal git responds to
            export PS1="${PX[ps1-mono]}"
            export LS_COLOR="--color=none"      # alt: "never"
            [ "${PX[git-project-name]}" ] &&
                export PS1="${PX[ps1-git-mono]}" || export PS1="${PX[ps1-mono]}"
        fi
    done
    # re-export PX array if 'PX[color]' changed
    [ "${PX[color]}" != "$prev_col" ] &&
        export PX_EXPORT="$(declare -p PX)"
}

# variables used in PS1 prompt to show path $PWD relative to $PRHOME (project HOME)
PRHOME=$HOME

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# cd() function overloading the 'cd' command to change prompt when entering
# git projects. Functions is only created when git is installed.
# Usage:
#  - cd directory
# \\
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
[ "${PX[has-git]}" ] &&
    \
    function cd() {
        [ -z "$1" ] && cd "$PRHOME" && return 0
        [ "$1" = "..." ] && cd "$HOME" && return 0
        [ -L "$1" ] && local is_link="true"
        [ ! -d "$1" ] && echo "cd $1: no such file or directory" && return 0 ||
            builtin cd "$1"
        # 
        [ "$is_link" ] && export PWD=$(pwd)
        # 
        # attempt to locate git project traversing upwards in directory tree
        local p="$PWD"
        while [[ ${#p} -gt 3 ]]; do
            [ -d "$p/.git" -a "$p" != "$HOME" -a "$p" != "/c/Sven1/svgr2" ] &&
                local proj_abs="$p" && break
            p=${p%/*}   # remove last part of path, same as: p=$(dirname "$p")
        done
        # 
        if [ "$proj_abs" ]; then
            if [ ! "$PRHOME" = "$proj_abs" ]; then
                PX[git-project-name]="${proj_abs//*\//}"    #  use last part of $proj_abs
                PRHOME="$proj_abs"
                [ "${PX[color]}" = "on" ] &&
                    export PS1="${PX[ps1-git-color]}" || export PS1="${PX[ps1-git-mono]}"
            fi
        else
            PRHOME="$HOME"; PX[git-project-name]=""
            [ "${PX[color]}" = "on" ] &&
                export PS1="${PX[ps1-color]}" || export PS1="${PX[ps1-mono]}"
        fi
        return 0
    }

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# useful aliases
# 
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

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# useful git aliases and functions, if git is installed
[ "${PX[has-git]}" ] &&
    alias gt="git status" &&
    alias switch="git switch" &&
    alias log="git log --oneline" &&
    alias br="git branch -avv" &&
    alias prune="git reflog expire --expire=now --all; git gc --prune=now --aggressive" &&
    alias gar="[ -d .git ] && tar cvf \$(date '+%y-%m%d-git.tar') .git || echo 'no .git directory'" &&
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

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# useful other functions
# 
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

# # trap demo function for zsh that does not work with trap enabled.
# For bash, a typed line in prompt is colored and reset with trap
# issuing the registered reset-color-sequence '\e[m' after ENTER:
# trap "echo -ne '\e[m'" DEBUG -- trap "" DEBUG clears trap.
# 
# function zsh_trap_demo() {
#     local code_path="$(tr ':' '\n' <<< $PATH | grep -i Code)"
#     ls -la "$code_path"
# }

# function cr2lf() {  # replace CR/LF (Windows) with newline (Unix) line endings
#     for f in $(crlf "$*"); do
#         echo "-- converting CRLF to '\n' in --> $f"
#         tmpfile="/tmp/$(basename "$f")"
#         sed 's/\r$//' < "$f" > "$tmpfile"
#         mv "$tmpfile" "$f"
#     done
# }

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# locate '.env.sh', 'env.sh' and '.bashrc' files in locations '.', '.env',
# 'env' and '~' and source first found file.
function source() {
    local arg=""; local flags=()
    for a in $@; do case "$a" in
        -*) flags+=($a) ;;
        *) [ -z "$arg" ] && arg="$a" ;;
        esac
    done
    # test main arg (no flag starting with '-')
    [ -f "$arg" ] && local file_to_source="$arg"
    [ -d "$arg" ] && local dir_to_source="${arg%/}"
    # 
    # sourcable files and directories
    local dirs=($dir_to_source . .env env "$HOME")
    local files=(.env.sh env.sh .bashrc)
    # 
    [ -z "$file_to_source" ] &&
        for dir in ${dirs[@]}; do
            dir=${dir%/}    # remove trailing '/'
            [ "$dir" = "." ] && dir="" || dir="$dir/"
            for file in ${files[@]}; do
                if [ "$arg" ]; then
                    arg=${arg%.}; arg=${arg%/}  # remove trailing '.' and '/'
                    [ -f "$dir$arg" ] && local file_to_source="$dir$arg" && break
                    [ -f "$arg/$file" ] && local file_to_source="$arg/$file" && break
                else
                    [ -f "$dir$file" ] && local file_to_source="$dir$file" && break
                fi
            done; [ "$file_to_source" ] && break
        done
    [ "$file_to_source" ] &&
        echo "sourcing: ${file_to_source/$HOME/\~} ${flags[@]}" &&
        builtin source "$file_to_source" ${flags[@]} || echo "--> error: $arg"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# run bash_rc() function, 'cd .' to set prompt in sub-shell
bash_rc "$1" &&
    cd . &&
    unset -f bash_rc

# For bash, enable coloring of typed line in prompt and reset with trap
# issuing the registered reset-color-sequence '\e[m' after ENTER with:
# trap "echo -ne '\e[m'" DEBUG -- trap "" DEBUG clears trap.
# 
[[ "$SHELL" =~ bash ]] && trap "echo -ne '\e[m'" DEBUG
