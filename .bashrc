# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# .profile:
# - SYS: Win:CYGWIN, Win:MINGW, Win:ZSH, WSL:Ubuntu, Linux
# - PATH: path
# - HOSTNAME_ALIAS: alias name for system hostname, e.g. 'X1' for 'LAPTOP-V50CGD0T'
# - HAS_GIT: true, false
# - ZSH: set in zsh
# - ENV_SH: source this file when entering directory of a git project, e.g. '.env.sh'
# 
# .bashrc:
# - TERM_HAS_COLORS: true, false
# - TERM: xterm-direct, xterm-256color, xterm-mono, dumb
# - LS_COLORS: 
# - PROMPT_COLOR: color, mono
# 
# - build_aliases()
# - build_prompt()
# - color(): on, off, true, false
# 
# .env-windows.sh
# - USER, USERNAME, HOME, PWD, PATH
# - env_Windows()
# 
# .ansi-colors.sh
# - ansi_code(), colorize_prompt(), colorize_ls_colors()
# 
# .git-cd.sh
# - GIT_PROJECT: 
# - GIT_PATH: 
# - cd()
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

echo ".bashrc"

type shopt &>/dev/null && if [[ $? ]]; then
    # check window size after each command and update values of LINES and COLUMNS
    shopt -s checkwinsize
    # append to the history file, don't overwrite it
    shopt -s histappend
fi
# avoid duplicate or empty (whitespaces) lines in history
# https://www.baeldung.com/linux/history-remove-avoid-duplicates
export HISTCONTROL=ignoreboth:erasedups
export HISTSIZE=999
export HISTFILESIZE=999

# source PATH variable from ~/.pathrc file for Windows environment
# [ -f ~/.paths ] && [[ "$SYS" =~ Win:. ]] && \
#     builtin source ~/.paths

# source color control functions for ANSI terminals
[ -f ~/.ansi-colors.sh ] && \
    builtin source ~/.ansi-colors.sh

[ -z "$TERM_HAS_COLORS" ] && \
    export TERM_HAS_COLORS=$([[ "$(tput colors)" -gt 1 ]] && \
        [ "$(typeset -f ansi_code)" ] && \
        echo true || echo false)

# overlay 'cd' command for PS1 prompt used within git projects,
# defines variables GIT_PROJECT with the name of git project and
# GIT_PATH with the path of git project
[ "$HAS_GIT" = true ] && \
    function cd() {
        local prior_value_of_GIT_PROJECT=$GIT_PROJECT
        # 
        [ "$1" ] && local cd_path=$1 && shift || local cd_path=$HOME
        # 
        # actually change directory
        builtin cd "$cd_path" $*
        # 
        export PWD=$(realpath . )   # set '\w' in PS1 prompt string
        local git_project=""
        local dir=$PWD
        # 
        while [ "$dir" != "/" -a "$dir" != "$HOME" ]; do
            [ -d "$dir/.git" ] && \
                git_project=$(basename "$dir") && \
                break
            dir=$(dirname "$dir")
        done
        # 
        [ "$git_project" ] && \
            local path=$(pwd) && \
            export GIT_PATH=${path/"$dir"/\.} || unset GIT_PATH
        # 
        # rebuild PS1 using the build_prompt function
        export GIT_PROJECT=$git_project
        build_prompt

        # test git-project was entered for the first time
        if [ -z "$prior_value_of_GIT_PROJECT" -a "$GIT_PROJECT" -a "$ENV_SH" ]; then
            # sourcing when $GIT_PROJECT is entered
            echo "entering GIT_PROJECT: $dir"
            [ -f "$dir"/$ENV_SH ] && builtin source "$dir"/$ENV_SH "$GIT_PROJECT" "$dir"
        fi
        # 
        if [ "$prior_value_of_GIT_PROJECT" -a -z "$GIT_PROJECT" ]; then
            # echo "leaving GIT_PROJECT: $prior_value_of_GIT_PROJECT"
            # invoke 'leave()' function if set by project environment
            [ "$(typeset -f leave)" ] && leave "$prior_value_of_GIT_PROJECT" "$dir"
            unset prior_value_of_GIT_PROJECT
        fi
    }

function build_aliases() {
    [ "$1" = "color" ] && local color="--color=auto" || local mvn_mono="-B"
    # 
    alias c="clear"
    alias aliases="alias"
    alias vi="vim"              # use vim for vi, -u ~/.vimrc
    alias ls="/bin/ls $color"   # colorize ls output
    alias l="ls -alFog"         # detailed list with dotfiles
    alias ll="ls -l"            # detailed list with no dotfiles
    alias grep="grep $color"
    alias egrep="egrep $color"
    alias pwd="pwd -LP"         # show real path with resolved links
    alias path="tr ':' '\n' <<< \$PATH"
    [ "$MAVEN_HOME" ] && \
        alias mvn="$MAVEN_HOME/bin/mvn $mvn_mono"   # -B: color off
    # 
    # set useful git aliases
    #  - prune, https://stackoverflow.com/questions/2116778/reduce-git-repository-size
    [ "$HAS_GIT" = true ] && \
        alias gt="git status" && \
        alias log="git log --oneline" && \
        alias br="git branch -avv" && \
        alias prune="git reflog expire --expire=now --all; git gc --prune=now --aggressive" && \
        alias gar="[ -d .git ] && tar cvf $(date '+%y-%m%d-git.tar') .git || echo 'no .git directory'" && \
        alias gls="git show --name-status"

    function source() { # source dotfile depending on $1 and location
        if [ -z "$1" ]; then
            [ -f "$ENV_SH" ] && local dotfile="$ENV_SH" || local dotfile="$HOME/.bashrc"
        else
            local dotfile="$1"
        fi
        echo "sourcing: $dotfile"; builtin source "$dotfile"
    }
    function env() {    # show environment variables
        [ "$1" == "--names" ] && sed -e 's/=.*//' <<< $(/usr/bin/env) && return
        [ "$1" ] && \
            for var in "$@"; do
                echo -ne "$var="; eval 'echo $'$var
            done || /usr/bin/env
    }
    function switch() {
        git switch $*
        local branch=$(git rev-parse --abbrev-ref HEAD)
        # show stashes that may exist for new branch
        stash | grep $branch
    }
    function stash() {  # git stash support
        case "$1" in
        +|.|push|--push) shift; git stash push; echo "-- created:"; stash ;;
        x|pop|--pop)     shift; git stash pop $* ;;
        # default case:
        *)  [ "$(git stash list)" ] && git stash list || \
                echo "[stash empty]"
        esac
    }
    # git diff: gd [--show] {0,1,2} file | 3 commit commit [file]
    function gd() {
        [ "$1" == "--show" ] && shift && local show=true
        local cmd=""
        case "$1" in
        # see stackoverflow: how-to-compare-the-working-tree-with-a-commit
        # 0: diff between staging area and last commit
        0)  cmd="git diff --cached $([ $2 ] && echo $2 || echo --name-status HEAD)" ;;
        # 1: diff between working tree and staging area
        1)  cmd="git diff $([ $2 ] && echo $2 || echo --name-status HEAD)" ;;
        # 2: diff between working tree and last commit (including staging diff)
        2)  cmd="git diff HEAD $([ $2 ] && echo $2 || echo --name-status)" ;;
        # 3: diff between two commits as file list or for specific file
        3)  [ -z "$2" ] && gd --help || \
                if [ "$4" ]; then
                    cmd="git diff $2..$3 -- $4"
                else
                    local p3=$([ "$3" ] && echo $3 || echo HEAD)
                    cmd="git diff --name-status $2..$p3"
                fi ;;
        *)  echo "usage: gd [--show] {0,1,2} file | 3 commit commit [file]" ;;
        esac
        [ "$show" ] && echo $cmd || $cmd    # show or execute $cmd
    }
    function rp() {     # show realpath of $1
        [ "$1" ] && realpath $* || realpath .
    }
    function h() {      # list history commands, select by $1
        [ "$1" == "--all" ] && history | uniq -f 1 && return
        [ "$1" ] && history | grep $1 | uniq -f 1 || history | tail -40
    }
    function tmux() {
        local tmux="/usr/bin/tmux"  # use full path in function overlay
        if [ "$1" == "kill" -o "$1" == "--kill" ]; then
            [ "$2" == "all" ] && "$tmux" kill-session -a && return
            [ "$2" == "server" ] && "$tmux" kill-server && return
            [ "$2" ] && shift && \
                for sid in "$@"; do
                    echo "removing session: $sid"; $tmux kill-session -t "$sid"
                done
        # 
        elif [ -z "$1" -o "$1" == "start" -o "$1" == "--start" ]; then
            [ "$2" ] && local profile="~/.tmux/$2.conf" || local profile="~/.tmux/default.conf"
            local profile_exp=$(eval echo "$profile")   # expand '~'
            [ -f "$profile_exp" ] && \
                eval /usr/bin/tmux new-session "\;" source-file "$profile_exp" || \
                echo "no matching profile: '"$profile"'"
        else
            "$tmux" $*
        fi
    }
    function functions() {  # list functions by name or specific function
        local fname="$1"
        [ "$fname" ] && typeset -f $fname || declare -F
    }
    [ "$OS" == "Windows_NT" ] && function explorer() {   # launch Windows explorer (Windows only)
        [ -z "$1" ] && local path="." || local path=$(tr '/' '\\' <<< $1)
        /c/WINDOWS/explorer.exe "$path"
    }
    function crlf() {   # list text files with CR/LF (Windows) line endings
        [ "$1" ] && local dir="$*" || local dir="."
        find "$dir" -not -type d -exec file "{}" ";" | grep CRLF | cut -d: -f1
    }
    function cr2lf() {  # replace CR/LF (Windows) with newline (Unix) line endings
        for f in $(crlf "$*"); do
            echo "-- converting CRLF to '\n' in --> $f"
            tmpfile="/tmp/$(basename "$f")"
            sed 's/\r$//' < "$f" > "$tmpfile"
            mv "$tmpfile" "$f"
        done
    }
}

function build_prompt() {
    # 
    if [ -z "$GIT_PROJECT" ]; then
        # no $GIT_PROJECT variable set means regular prompt (not inside git project)
        # GNU prompt control sequences for PS1 variable
        # https://www.gnu.org/software/bash/manual/html_node/Controlling-the-Prompt.html
        # PS1='\[\e[32m\]\u@\h:\W> \[\e[0m\]'
        local regular_prompt=(
            white       '\\\\\\\n'
            green       '\! '           # \! history number, \# command number
            low-green   '\u@\047$HOSTNAME_ALIAS\047 '   # \u user, \h hostname
            # low-white   '($(date "+%H:%M")) '
            low-white   '(\D{%H:%M}) '
            yellow      '\w '           # \w path relative to $HOME, \W only dirname
            reset       '\012'          # newline (must be \012, not \n)
            white       # color for typed command
        )
        PS1=$(colorize_prompt "$PROMPT_COLOR" "${regular_prompt[@]}")
    # 
    else
        # prompt inside git project
        local git_prompt=(
            white       '\\\\\\\n'
            green       '\! '           # \! history number, \# command number
            low-green   '\u@\047$HOSTNAME_ALIAS\047 '   # \u user, \h hostname
            blue        "$GIT_PROJECT "
            white       '['
            # purple      '$(git branch --show-current)'    # not working on Ubuntu
            purple      '$(git symbolic-ref --short HEAD 2>/dev/null)'
            white       '] '
            yellow      "$GIT_PATH"
            reset       '\012'          # newline (must be \012, not \n)
            white       # color for typed command
        )
        PS1=$(colorize_prompt "$PROMPT_COLOR" "${git_prompt[@]}")
    fi
    # 
    if [ "$PROMPT_COLOR" = true ]; then
        trap "echo -ne '\e[m'" DEBUG    # reset formatting after command + ENTER
    else
        trap "" DEBUG
    fi
}

function color() {
    [ "$1" = "on" ] && color true && return
    [ "$1" = "off" ] && color false && return
    # 
    if [ "$1" = true ] && [ "$TERM_HAS_COLORS" = true ]; then
        # 
        # vim coloring requires "xterm-256color"
        export TERM="xterm-256color"
        #
        # Set coloring scheme for 'ls' command (with --color=auto)
        # https://www.bigsoft.co.uk/blog/2008/04/11/configuring-ls_colors
        # - di: directory
        # - fi: file
        # - ow: directory that is other-writable (o+w) and not sticky
        # - ln: symbolic link
        # - or: orphan, broken symbolic link
        # - mi: missing file for symbolic link
        # - ex: executable file
        # 
        # export LS_COLORS="di=1;36:ln=1;31:fi=36:ex=36:*.tar=1;37"
        # export LS_COLORS="di=1;97:ow=1;37:ln=1;34:fi=0;37:ex=0;31:*.tar=0;36:*.jar=0;36"
        # 
        # set dircolors database, show with `dircolors --print-database` command
        export LS_COLORS=$(colorize_ls_colors \
            "di"    bright-white \
            "ow"    white \
            "fi"    low-white \
            "ex"    red \
            "ln"    blue \
            "or"    blue \
            "mi"    broken-link \
            "*.zip" low-cyan \
            "*.tar" low-cyan \
            "*.jar" low-cyan \
        )
        case "$SYS" in
            # overwrite LS_COLORS for WSL:Ubuntu with:
            # - ex: red -> low-white (WSL:Ubuntu shows all files as executable),
            # - ln, or: blue -> cyan
            WSL:Ubuntu) export LS_COLORS+=":"$(colorize_ls_colors \
                "ex"    low-white \
                "ln"    cyan \
                "or"    cyan \
            ) ;;
        esac
        build_aliases color

        [ "$HAS_GIT" = true ] && \
            $(git config color.ui true 2>/dev/null)

        export PROMPT_COLOR=true
        build_prompt
    # 
    else
        export TERM="xterm-mono"
        # export TERM="dumb"    # alternative: "dumb" to disable colors in vi
        # 
        export LS_COLORS=$(colorize_ls_colors \
            "rs" 0 "di" 0 "ln" 0 "mh" 0 "pi" 0 "so" 0 "do" 0 "bd" 0 \
            "cd" 0 "or" 0 "mi" 0 "su" 0 "sg" 0 "ca" 0 "tw" 0 "ow" 0 \
            "st" 0 "ex" 0 \
        )
        build_aliases mono

        [ "$HAS_GIT" = true ] && \
            $(git config color.ui false 2>/dev/null)

        export PROMPT_COLOR=false
        build_prompt
    fi
}

if [[ ! "$SYS" =~ .*ZSH ]]; then
    [ "$PROMPT_COLOR" ] && \
        color $PROMPT_COLOR || color $TERM_HAS_COLORS
else
    # zsh only set aliases, but no color or prompt
    build_aliases
fi

# cd to start directory, if passed as START_DIR environment variable
# when shell is started in arbitrary directory, e.g. from context menu
[ "$START_DIR" ] && \
    cd "$START_DIR"

unset START_DIR      # remove start directory
