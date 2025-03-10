
# import PX associative array into child-shell from 'PX_EXPORT' variable, see brilliant advice at
# https://stackoverflow.com/questions/65341786/shell-script-pass-associative-array-to-another-shell-script
# 
if [ "$PX_EXPORT" ]; then
    declare -A PX="${PX_EXPORT#*=}"
fi

[ "${PX[log]}" ] && echo ".bashrc"

type shopt &>/dev/null && if [[ $? ]]; then
    # check window size after each command and update values of LINES and COLUMNS
    shopt -s checkwinsize
    # append to the history file, don't overwrite
    shopt -s histappend
fi


function setup_bash() {
    # 
    # strange effect with zsh that 'proj_abs' has 3 ANSI ESC chars in front
    if [ -z "${PX[has-color]}" ]; then
        local colors=$(/usr/bin/tput colors)
        [[ "$SHELL" =~ zsh ]] && colors="${colors:3}"
        [[ "$colors" -gt 1 ]] && PX[has-color]="true"
    fi

    case "$SHELL" in
    *bash)
        # 
        # GNU prompt control sequences for PS1 variable
        # https://www.gnu.org/software/bash/manual/html_node/Controlling-the-Prompt.html
        # 
        # PS1='\[\e[32m\]\u@\h:\W> \[\e[0m\]'
        # export PS1=$(echo -e '\033]0;${PWD}\n\033[32m${USER}@${HOSTNAME} \033[33m${PWD/${HOME}/\~}\033[0m\n$ ')
        # export PS1_color=$(echo -e '\033[0m\! \033[32m${USER}@${HOSTNAME} \033[33m${PWD/${HOME}/\~}\033[0m\n$ ')
        # export PS1_mono=$(echo -e '\! ${USER}@${HOSTNAME} ${PWD/${HOME}/\~}\n$ ')
        # 
        local reg_prompt=(
            # reset     '\\\\\\\\\ \n'          # '\\' + '\n'
            # reset     '\\\\\\\\\\\\\\\\\ \\n' # '\\' + '\n'
            reset       '\\\\\\\\\ \n'          # '\\' + '\n'
            green       '\! '                   # \! history number, \# command number
            low-green   '\u@\047$HOSTNAME\047 ' # \u user, \h hostname
            low-white   '(\D{%H:%M}) '          # time: (hh:mm)
            yellow      '\w '                   # \w path relative to $HOME, \W only dirname
            # yellow    '${PWD/${RPATH}/\~} '
            white       '\n$ '                  # newline + '$' (may need to be \012, not \n)
            white                               # color for typed command
        )
        local git_prompt=(
            # reset     '\\\\\\\\\\\\\\\\\ \\n' # '\\' + '\n'
            reset       '\\\\\\\\\ \n'          # '\\' + '\n'
            green       '\! '                   # \! history number, \# command number
            # low-green   '\u@\047$HOSTNAME\047 ' # \u user, \h hostname
            # 
            white       '['                     # show poject name in git-prompt
            blue        '${PX[git-project-name]}'
            white       '] '
            # 
            white       '['                     # show branch in git-prompt
            purple      '$(git symbolic-ref --short HEAD 2>/dev/null)'
            white       '] '
            # 
            red         '${RPWD/${RPATH}/\~} '  # path relative to project directory
            white       '\n$ '                  # newline + '$' (may need to be \012, not \n)
            white                               # color for typed command
        )
        PX[ps1-color]=$(colorize_prompt true "${reg_prompt[@]}")
        PX[ps1-mono]=$(colorize_prompt false "${reg_prompt[@]}")
        PX[ps1-git-color]=$(colorize_prompt true "${git_prompt[@]}")
        PX[ps1-git-mono]=$(colorize_prompt false "${git_prompt[@]}")
        ;;

    *zsh)
        [ "${PX[log]}" ] && echo -n ".zprofile"
        # 
        # Building a custom zsh prompt from scratch
        # https://amitosh.medium.com/building-a-custom-zsh-prompt-from-scratch-3ff9fcbad67e
        # https://zsh.sourceforge.io/Doc/Release/Prompt-Expansion.html
        # 
        # export PROMPT=$(echo -e '\033[32m%n@%m \033[33m%~\033[0m\n$ ')   # '%m %1d$ ' #'%n@%m %~$ '
        # export PROMPT=$(echo -e '%n@%m %~\n$ ')   # '%m %1d$ ' #'%n@%m %~$ '
        # export PS1_color=$(echo -e '%h %# \033[32m%n@%m \033[33m%~\033[0m\n$ ')   # '%m %1d$ ' #'%n@%m %~$ '
        # export PS1_mono=$(echo -e '%h %n@%m %~\n$ ')   # '%m %1d$ ' #'%n@%m %~$ '
        # 
        export HOST="$HOSTNAME"             # zsh prompt '%m' refers to 'HOST'
        local reg_prompt=(
            # reset       '\\\\\ \\n'       # '\\' + '\n'
            reset       '-- \n'             # '--' + '\n'
            blue        '(%h) '             # (history number)
            blue        '%n@\047%m\047 '    # user@'host'
            low-white   '(%D{%K:%M}) '      # time: (hh:mm)
            yellow      '%~'                # path relative to $HOME
            white       '\n-> '             # newline + '->' (may need to be \012, not \n)
            white                           # color for typed command
        )
        local git_prompt=(
            reset       '-- \n'             # '--' + '\n'
            blue        '(%h) '             # (history number)
            blue        '%n@\047%m\047 '    # user@'host'
            low-white   '(%D{%K:%M}) '      # time: (hh:mm)
            red         '%~'                # path relative to $HOME
            white       '\n-> '             # newline + '->' (may need to be \012, not \n)
            white                           # color for typed command
        )
        PX[ps1-color]=$(colorize_prompt true "${reg_prompt[@]}")
        PX[ps1-mono]=$(colorize_prompt false "${reg_prompt[@]}")
        PX[ps1-git-color]=$(colorize_prompt true "${git_prompt[@]}")
        PX[ps1-git-mono]=$(colorize_prompt false "${git_prompt[@]}")
        ;;
    esac

    [ -z "$LS_COLORS" ] && \
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
    # 
    if [ "${PX[color]}" ]; then
        # must set PS1 in sub-shell
        color "${PX[color]}"    # set color 'on' or 'off'
    else
        [ "${PX[has-color]}" = true ] && color on || color off
    fi
    # 
    # export PX associative array via 'PX_EXPORT' variable to pass to child-shell, see brilliant advice at
    # https://stackoverflow.com/questions/65341786/shell-script-pass-associative-array-to-another-shell-script
    # 
    [ -z "$PX_EXPORT" ] && \
        export PX_EXPORT="$(declare -p PX)"
}

function ansi_code() {
    local code="$1"; local text="$2";
    [[ "$SHELL" =~ zsh ]] && \
        local reset="\e[0m" || \
        local reset="\[\e[0m\]"     # alternatively: "\[\e[0m\]", "\[\033[0m\]"
    # 
    case "$code" in
    "reset")    printf "%s%s" "$reset" "$text" ;;   # echo -e "$reset""$text" ;;
    "0")        printf "0" ;;                       # echo -e "0" ;;
    *)          local esc="${ANSI_COLORS[$code]}"
                [ "$text" = "--unterminated" ] && text="" && reset=""
                # [ "$esc" ] && printf "\[\e[%sm\]%s%s" "$esc" "$text" "$reset" ;;
                if [ "$esc" ]; then
                    [[ "$SHELL" =~ zsh ]] && \
                        echo -e "\e["$esc"m""$text""$reset" || \
                        echo -e "\[\e["$esc"m\]""$text""$reset"
                fi ;;
    esac
}

function colorize_prompt() {
    # arg1 tells to set color (true) or not (false)
    local s=0; local code=""; local e=""
    for k in "$@"; do
        [ "$s" = 0 -a "$k" = false ] && s=10 && continue
        [ "$s" = 0 -a "$k" = true ] && s=20 && continue
        # 
        # monochrome prompt
        [ "$s" = 10 ] && s=11 && continue
        [ "$s" = 11 ] && s=10 && e+="$k" && continue
        # 
        # colored prompt
        [ "$s" = 20 ] && s=21 && code="$k" && continue
        [ "$s" = 21 ] && s=20 && \
            e+=$(ansi_code "$code" "$k") && \
            code="" && continue
    done;
    # 
    # append unterminated color code (no '\[\e[0m\]' after text) to
    # allow colored typing (commands)
    [ "$1" = true ] && [ "$code" ] && e+=$(ansi_code "$code" "--unterminated")
    # 
    echo -e "$e"    # printf "%s" "$e"  # output sequence for prompt (must quote "$e")
}

function colorize_ls_colors() {
    local s=0; local e=""
    for k in "$@"; do
        [ "$s" = 1 ] && e+="${ANSI_COLORS[$k]}" && s=2
        [ "$s" = 0 ] && e+="$k=" && s=1
        [ "$s" = 2 ] && e+=":" && s=0
    done;
    echo -e "$e"    # printf "%s" "$e"  # output sequence for LS_COLORS (must quote "$e")
}

function color() {
    local prev_col="${PX[color]}"
    for arg in $*; do
        [ "${PX[log]}" ] && echo "turn color $arg"
        # 
        if [ "$arg" = "on" -a "${PX[has-color]}" ]; then
            PX[color]="on"
            export LS_COLOR="--color=auto"
            [ "${PX[git-project-name]}" ] && \
                export PS1="${PX[ps1-git-color]}" || export PS1="${PX[ps1-color]}"
            # 
            trap "echo -ne '\e[m'" DEBUG    # reset formatting after command + ENTER
        fi
        if [ "$arg" = "off" ]; then
            PX[color]="off"
            export PS1="${PX[ps1-mono]}"
            export LS_COLOR="--color=none"  # alt: "never"
            [ "${PX[git-project-name]}" ] && \
                export PS1="${PX[ps1-git-mono]}" || export PS1="${PX[ps1-mono]}"
        fi
    done
    # 
    # re-export PX array due if changed 'PX[color]' changed
    [ "${PX[color]}" != "$prev_col" ] && \
        export PX_EXPORT="$(declare -p PX)"
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# ANSI terminal control sequences for colors:
# - https://en.wikipedia.org/wiki/ANSI_escape_code
# - https://askubuntu.com/questions/466198/how-do-i-change-the-color-for-directories-with-ls-in-the-console
# - https://www.howtogeek.com/307701/how-to-customize-and-colorize-your-bash-prompt
# 
declare -gA ANSI_COLORS=(
    ["black"]="1;30"
    ["dimmed-grey"]="2;30"  ["dimmed-red"]="2;31"   ["dimmed-green"]="2;32"
    ["dimmed-yellow"]="2;33" ["dimmed-blue"]="2;34" ["dimmed-purple"]="2;35"
    ["dimmed-cyan"]="2;36"  ["dimmed-white"]="2;37"

    ["grey"]="1;30"         ["red"]="1;31"          ["green"]="1;32"
    ["yellow"]="1;33"       ["blue"]="1;34"         ["purple"]="1;35"
    ["cyan"]="1;36"         ["white"]="1;37"

    ["low-grey"]="0;30"     ["low-red"]="0;31"      ["low-green"]="0;32"
    ["low-yellow"]="0;33"   ["low-blue"]="0;34"     ["low-purple"]="0;35"
    ["low-cyan"]="0;36"     ["low-white"]="0;37"    # ["low-white"]="0;37;1"

    ["bright-grey"]="1;90"  ["bright-red"]="1;91"   ["bright-green"]="1;92"
    ["bright-yellow"]="1;93" ["bright-blue"]="1;94" ["bright-purple"]="1;95"
    ["bright-cyan"]="1;96"  # turquoise
    ["bright-white"]="1;97" # boldish bright white
    ["light-red-bg"]="1;101"

    ["broken-link"]="1;4;37;41" # used for broken links (white on red background)
)

# https://stackoverflow.com/questions/6159856/how-do-zsh-ansi-colour-codes-work
# for COLOR in {0..255}; do
#     for STYLE in "38;5"; do 
#         TAG="\033[${STYLE};${COLOR}m"
#         STR="${STYLE};${COLOR}"
#         echo -ne "${TAG}${STR}${NONE}  "
#     done
#     echo
# done

# further control sequences for ANSI terminal:
# - Put the cursor at line L and column C \033[<L>;<C>H
# - Put the cursor at line L and column C \033[<L>;<C>f
# - Move the cursor up N lines            \033[<N>A
# - Move the cursor down N lines          \033[<N>B
# - Move the cursor forward N columns     \033[<N>C
# - Move the cursor backward N columns    \033[<N>D
# - Clear the screen, move to (0,0)       \033[2J
# - Erase to end of line                  \033[K
# - Save cursor position                  \033[s
# - Restore cursor position               \033[u
# 
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# set 'has-git' and 'has-realpath' if not coming through .login shell
[ -z "${PX[has-git]}" -a -z "${PX[has-realpath]}" ] && \
    for cmd in git realpath; do
        p=$(which "$cmd" 2>/dev/null)
        case "$p" in
        */realpath)     PX[has-realpath]="true" ;;
        */git)          PX[has-git]="true" ;;
        esac
    done

RPATH=$HOME
RPWD=$HOME

# probe for git and realpath commands and, if present, overload 'cd' for git-prompt
[ "${PX[has-git]}" -a "${PX[has-realpath]}" = true ] && \
    \
    function cd() {
        [ "$1" ] && builtin cd "$1" || builtin cd "$HOME"
        RPWD=$(realpath "$PWD")
        # 
        # locate project directory, if cd'ed deep into a git project
        for d in . .. ../.. ../../.. ../../../.. ../../../../.. ; do
            [ -d "$d/.git" ] && \
                local proj="$d" && break
        done
        if [ "$proj" ]; then
            # strange effect with zsh that 'proj_abs' has 3 unprintable chars in front
            [[ "$SHELL" =~ zsh ]] && \
                local proj_abs=$(realpath "$proj") && proj_abs="${proj_abs:3}" || \
                local proj_abs=$(realpath "$proj")
            # 
            [ "$proj_abs" = "$HOME" ] && proj_abs=""
            [ "$proj_abs" = "/c/Sven1/svgr2" ] && proj_abs=""
        fi
        if [ "$proj_abs" ]; then
            if [ ! "$RPATH" = "$proj_abs" ]; then
                PX[git-project-name]="${proj_abs//*\//}"    #  use last part of $proj_abs
                RPATH="$proj_abs"
                [ "${PX[color]}" = "on" ] && \
                    export PS1="${PX[ps1-git-color]}" || export PS1="${PX[ps1-git-mono]}"
            fi
        else
            RPATH="$HOME"
            PX[git-project-name]=""
            [ "${PX[color]}" = "on" ] && \
                export PS1="${PX[ps1-color]}" || export PS1="${PX[ps1-mono]}"
        fi
    }


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
                                # supress env var with prompt strings, e.g. PS1, PX_EXPORT
alias env="/usr/bin/env | grep -v '\['"
# 
[ "$MAVEN_HOME" ] && \
    alias mvn="$MAVEN_HOME/bin/mvn $mvn_mono"   # -B: color off
# 
function h() {      # list history commands, select by $1
    [ "$1" == "--all" ] && history | uniq -f 1 && return
    [ "$1" ] && history | grep $1 | uniq -f 1 || history | tail -40
}

# set up git aliases, if git is installed
[ "${PX[has-git]}" ] && \
    alias gt="git status" && \
    alias log="git log --oneline" && \
    alias br="git branch -avv" && \
    alias switch="git switch" && \
    alias prune="git reflog expire --expire=now --all; git gc --prune=now --aggressive" && \
    alias gar="[ -d .git ] && tar cvf \$(date '+%y-%m%d-git.tar') .git || echo 'no .git directory'" && \
    alias gls="git show --name-status"

setup_bash && \
    unset -f setup_bash

cd .
