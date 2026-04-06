#!/bin/bash
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# .profile is executed by the bash shell process when a new terminal is opened.
# It is not executed by bash sub-processes. Counterpart is .bash_logout that
# is executed when the terminal session is closed.
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# 
# extend PATH to find UNIX commands such as 'hostname'
PATH="$PATH:/usr/bin:/bin:/usr/local/bin"

# map custom hostnames
[ -z "$HOSTNAME" ] && host=$(hostname) || host="$HOSTNAME"
case "$host" in
    LAPTOP-V50CGD0T) host="X1-G4W10" ;;     # map HOSTNAME to alias HOSTNAME used in prompt
    DESKTOP-7T2AG34) host="X1-G4.11" ;;     # X1 Carbon Laptop after Win11-upgrade Aug 2024/25
esac
[ -z "$HOSTNAME" -o "$host" != "$HOSTNAME" ] && export HOSTNAME="$host"

# locate .bashrc.px[.$HOSTNAME] file with cached PX[] array settings (not cached for zsh)
[ -z "$HOME" ] && export HOME="."; pxfile="$HOME/.bashrc.px.$host"
[ ! -f "$pxfile" ] && pxfile="$HOME/.bashrc.px" && [ ! -f "$pxfile" ] && pxfile=""
# 
# load PX[] array from $pxfile cache for faster start-up or initialize if no $pxfile is present
if [ "$pxfile" -a -z "$ZSH" ]; then
    export PX_EXPORT="$(cat $pxfile)"   # export to unpack PX[] in sub-processes
    declare -A PX="${PX_EXPORT#*=}"
    PX[declared]=""                     # mark PX as not declared
    PX[color]=""                        # reset color to force setting in color() function
else
    declare -gA PX
    PX[clean-envar]="true"              # clean-up environment variables inherited on Windows
    PX[has-color]=""                    # terminal has colors: true or false
    PX[color]=""                        # current color setting: 'on' or 'off'
    PX[term]=""                         # alternate TERM setting to color 'on' or 'off'
    PX[has-git]=""                      # git is installed
    PX[has-realpath]=""                 # realpath command is present
    PX[has-cygpath]=""                  # cygpath command is present
    PX[git-project-name]=""             # name of current git project or ""
    PX[bashrc-ext]=".bashrc.path"       # platform-specific .bashrc extension file, e.g. '.bashrc-win-x1'
    PX[bashrc-px]=".bashrc.px"          # platform-specific file to store PX[], e.g. '.bashrc-win-x1.px'
    PX[APPDATA_CYG]=""                  # cygified APPDATA path
    # 
    PX[ps1-color]=""                    # patterns for PS1 command line prompts
    PX[ps1-mono]=""
    PX[ps1-git-color]=""
    PX[ps1-git-mono]=""
    PX[ls-colors]=""                    # settings for LS_COLORS environment variable
    #                                   # remove files from $HOME
    PX[declared]="true"                 # mark PX as declared
fi

PX[log]=""                              # set 'true' to enable logging
# 
if [ "${PX[log]}" ]; then               # log script execution
    [ "${PX[declared]}" ] && echo "declared PX[]" || echo "loaded PX[] from $pxfile"
    [ "$ZSH" ] && echo -n ".zprofile -> .profile" || echo -n ".profile"
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# profile() function
#  - set environment variables: PATH, USER, LANG, SHELL, START_DIR, LS_COLORS
#    LC_COLLATE, HISTORYCONTROL, HISTORYSIZE, HISTORYFILESIZE, LESSHISTFILE
#  - clear env from variables inherited from Windows (on Windows only)
#  - invoke .bashrc for bash
# \\
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function profile() {
    # 
    # locate commands from prior PATH and append to Unix PATH
    local path_ext=""
    for cmd in git realpath cygpath code powershell; do
        p=$(which "$cmd" 2>/dev/null)
        case "$p" in
        */realpath)     PX[has-realpath]="true" ;;
        */cygpath)      PX[has-cygpath]="true" ;;
        */git)          PX[has-git]="true"; path_ext+=":"$(dirname "$p") ;;
        */code)         path_ext+=":"$(dirname "$p") ;;
        */powershell)   path_ext+=":"$(dirname "$p") ;;
        esac
    done; export PATH=".:/usr/local/bin:/usr/bin:/bin$path_ext"

    # Windows: clean-up environment, 'OS' only exists on Windows
    if [[ "$OS" && "$OS" =~ Windows ]]; then
        if [ "${PX[clean-envar]}" ]; then
            # remove environment variables inherited from Windows, except those in match patterns
            local remove=()
            for v in $(sed -e 's/=.*//' <<< $(env)); do
                # cannot unset strange var: 'ProgramFiles(x86)' 'CommonProgramFiles(x86)' '!::', '_'
                [[ "$v" =~  (ProgramFiles.x86.|^!::$|^_$) ]] && continue
                # keep these variables, PROFILEREAD is read-only with zsh and can't be unset
                [[ "$v" =~ ^(APPDATA|START_DIR|PATH|HOME|SHELL|TERM|OSTYPE|HOSTNAME|USERPROFILE|SYSTEMROOT|PROFILEREAD)$ ]] && \
                    continue
                remove+=($v)
            done
            # remove all other environment variables inherited from Windows
            [[ ${#remove[@]} -gt 0 ]] && unset ${remove[@]}
        fi
        export USER="$(/usr/bin/id -un)"    # alt: USER=$(whoami)
        export LANG=$(/usr/bin/locale -uU)
        [ "$APPDATA" -a -z "${PX[APPDATA_CYG]}" ] && PX[APPDATA_CYG]=$(cygpath "$APPDATA")
        # 
        # ignore Windows \r line ends, otherwise error: '\r': command not found in .bashrc
        (set -o igncr) 2>/dev/null && set -o igncr;
        # 
        # change Windows default code page (437) to UTF-8 (65001), see:
        # https://superuser.com/questions/269818/change-default-code-page-of-windows-console-to-utf-8/269857#269857
        $(cygpath ${SYSTEMROOT})/system32/chcp.com 65001 &>/dev/null
    fi

    [ -z "$SHELL" ] && export SHELL="$(ps -p $$ | sed -e '/PID/d' -e 's/.* //g')"
    [ "${PX[has-realpath]}" ] && export HOME=$(realpath "$HOME")
    [ "${PX[has-cygpath]}" -a "$START_DIR" ] && export START_DIR=$(cygpath "${START_DIR//\"/}")
    [ -z "$LANG" ] && export LANG="en_US.UTF-8"
    # 
    PX[term]="$TERM"    # save TERM to toggle with 'dumb' monochrome terminal
    # 
    # remove write permission for group and others (files are normally created
    # with mode 777 become 755; files created with mode 666 become 644)
    umask 022

    # - - - - - - - - - - - -
    case "$OSTYPE" in
    cygwin) ;;  # Windows, cygwin emulator
    msys)   ;;  # Windows, mingw emulator used for GitBash
    linux*)
            # show dotfiles first and not merged for 'ls'-list (as WSL:Ubuntu does)
            export LC_COLLATE="C" ;;
    esac

    # - - - - - - - - - - - -
    # avoid duplicate or empty (whitespaces) lines in history
    # https://www.baeldung.com/linux/history-remove-avoid-duplicates
    export HISTCONTROL=ignoreboth:erasedups
    export HISTSIZE=999
    export HISTFILESIZE=999
    export LESSHISTFILE=-           # supress creation of .lesshst file

    # compute coloring sequences (ANSI colors) and store in PX[] when array
    # was not loaded from cached .px file, remove coloring functions after
    [ "${PX[declared]}" ] &&
        build_colors &&
        unset -f build_colors ansi_code colorize_prompt colorize_ls_colors
    # 
    export LS_COLORS="${PX[ls-colors]}"

    # bash does not run ~/.bashrc implicitely, launch explicitely with LOGIN arg
    [[ "$SHELL" =~ bash && -f "$HOME/.bashrc" ]] && \
        builtin source "$HOME/.bashrc" LOGIN
    # 
    return 0
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# define coloring functions only when PX[] was not loaded from .px file and
# coloring sequences (ANSI colors) need to be computed
# 
if [ "${PX[declared]}" ]; then
    # 
    function build_colors() {
        case "$SHELL" in
        *bash)
            # GNU prompt control sequences for PS1 variable
            # https://www.gnu.org/software/bash/manual/html_node/Controlling-the-Prompt.html
            # 
            # PS1='\[\e[32m\]\u@\h:\W> \[\e[0m\]'
            # export PS1=$(echo -e '\033]0;${PWD}\n\033[32m${USER}@${HOSTNAME} \033[33m${PWD/${HOME}/\~}\033[0m\n$ ')
            # export PS1_color=$(echo -e '\033[0m\! \033[32m${USER}@${HOSTNAME} \033[33m${PWD/${HOME}/\~}\033[0m\n$ ')
            # export PS1_mono=$(echo -e '\! ${USER}@${HOSTNAME} ${PWD/${HOME}/\~}\n$ ')
            # 
            local reg_prompt=(
                reset       '\\\\\\\\\ \n'          # '\\' + '\n'
                green       '\! '                   # \! history number, \# command number
                low-green   '\u@\047$HOSTNAME\047 ' # \u user, \h hostname
                low-white   '(\D{%H:%M}) '          # time: (hh:mm)
                yellow      '\w '                   # \w path relative to $HOME, \W only dirname
                # yellow    '${PWD/${PRHOME}/\~} '
                white       '\n$ '                  # newline + '$' (may need to be \012, not \n)
                white                               # color for typed command
            )
            local git_prompt=(
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
                red         '${PWD/${PRHOME}/\~} '  # path relative to project directory
                white       '\n$ '                  # newline + '$' (may need to be \012, not \n)
                white                               # color for typed command
            )
            PX[ps1-color]=$(colorize_prompt true "${reg_prompt[@]}")
            PX[ps1-mono]=$(colorize_prompt false "${reg_prompt[@]}")
            PX[ps1-git-color]=$(colorize_prompt true "${git_prompt[@]}")
            PX[ps1-git-mono]=$(colorize_prompt false "${git_prompt[@]}")
            ;;

        *zsh)
            # Building a custom zsh prompt from scratch
            # https://amitosh.medium.com/building-a-custom-zsh-prompt-from-scratch-3ff9fcbad67e
            # https://zsh.sourceforge.io/Doc/Release/Prompt-Expansion.html
            # 
            # export PROMPT=$(echo -e '\033[32m%n@%m \033[33m%~\033[0m\n$ ')   # '%m %1d$ ' #'%n@%m %~$ '
            # export PROMPT=$(echo -e '%n@%m %~\n$ ')   # '%m %1d$ ' #'%n@%m %~$ '
            # export PS1_color=$(echo -e '%h %# \033[32m%n@%m \033[33m%~\033[0m\n$ ')   # '%m %1d$ ' #'%n@%m %~$ '
            # export PS1_mono=$(echo -e '%h %n@%m %~\n$ ')   # '%m %1d$ ' #'%n@%m %~$ '
            # 
            # export HOST="$HOSTNAME"                 # zsh prompt '%m' refers to 'HOST'
            local reg_prompt=(
                # reset       '\\\\\ \\n'           # '\\' + '\n'
                reset       '-- \n'                 # '--' + '\n'
                blue        '(%h) '                 # (history number)
                blue        '%n@\047%m\047 '        # user@'host'
                low-white   '(%D{%K:%M}) '          # time: (hh:mm)
                yellow      '%~'                    # path relative to $HOME
                white       '\n-> '                 # newline + '->' (may need to be \012, not \n)
                reset       ''                      # reset coloring for typed line since trap has issues with sub-processes in zsh $(...)
            )
            local git_prompt=(
                reset       '-- \n'                 # '--' + '\n'
                green       '%h '                   # (history number)
                # 
                white       '['                     # show poject name in git-prompt
                # blue        '$(echo -e "\e[1;34m"${PX[git-project-name]})'
                blue        '${PX[git-project-name]}'
                white       '] '
                # 
                white       '['                     # show branch in git-prompt
                # remove ANSI reset seq "\e[0m" injected by zsh in front of 'branch' variable in $(git ...) execution
                # purple      '$(branch=$(git symbolic-ref --short HEAD 2>/dev/null); [ ${PX[color]} = "on" ] && echo -e -n "\e[1;35m"; echo -n "${branch#*[a-zA-Z]}")'
                # purple      '$([ ${PX[color]} = "on" ] && trap "" DEBUG && echo -e -n "\e[1;35m"; git symbolic-ref --short HEAD 2>/dev/null)'
                purple      '$([ ${PX[color]} = "on" ] && echo -e -n "\e[1;35m"; git symbolic-ref --short HEAD 2>/dev/null)'
                white       '] '
                # 
                # red         '%~'                  # path relative to $HOME
                # red         '${PWD/${PRHOME}/~}'  # path relative to project directory
                # red         '$([ ${PX[color]} = "on" ] && trap "" DEBUG && echo -e -n "\e[1;31m"; echo "${PWD/${PRHOME}/~}")'
                red         '$([ ${PX[color]} = "on" ] && echo -e -n "\e[1;31m"; echo "${PWD/${PRHOME}/~}")'
                white       '\n-> '                 # newline + '->' (may need to be \012, not \n)
                reset       ''                      # reset coloring for typed line since trap has issues with sub-processes in zsh $(...)
            )
            PX[ps1-color]=$(colorize_prompt true "${reg_prompt[@]}")
            PX[ps1-mono]=$(colorize_prompt false "${reg_prompt[@]}")
            PX[ps1-git-color]=$(colorize_prompt true "${git_prompt[@]}")
            PX[ps1-git-mono]=$(colorize_prompt false "${git_prompt[@]}")
            ;;
        esac

        # "ex" used to be 'red'
        PX[ls-colors]=$(colorize_ls_colors \
            "di"    bright-white \
            "ow"    white \
            "fi"    low-white \
            "ex"    low-white \
            "ln"    blue \
            "or"    blue \
            "mi"    broken-link \
            "*.zip" low-cyan \
            "*.tar" low-cyan \
            "*.jar" low-cyan \
        )
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
        # append unterminated color code (no '\[\e[0m\]' after text) for colored typing commands
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

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    # ANSI terminal control sequences for colors:
    # - https://en.wikipedia.org/wiki/ANSI_escape_code
    # - https://askubuntu.com/questions/466198/how-do-i-change-the-color-for-directories-with-ls-in-the-console
    # - https://www.howtogeek.com/307701/how-to-customize-and-colorize-your-bash-prompt
    # 
    # remove ansi color codes from output
    # - https://stackoverflow.com/questions/32166976/how-to-remove-the-decorate-colors-characters-in-bash-output
    # - https://stackoverflow.com/questions/19296667/remove-ansi-color-codes-from-a-text-file-using-bash
    # - sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g"
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
    # 
    # https://stackoverflow.com/questions/6159856/how-do-zsh-ansi-colour-codes-work
    # for COLOR in {0..255}; do
    #     for STYLE in "38;5"; do 
    #         TAG="\033[${STYLE};${COLOR}m"
    #         STR="${STYLE};${COLOR}"
    #         echo -ne "${TAG}${STR}${NONE}  "
    #     done
    #     echo
    # done
    # 
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
    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Sync two files. Copy f1->f2, if f1 has a newer modification time than f2, and
# vice versa f2->f1, if f2 has a newer modification time than f1. Create the
# complementary file if missing. Log sync operation if log file is specified.
# Usage:
# - sync_files file-1 file-2 [log-file]
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function sync_files {
    [ -f "$1" ] && local f1="$1"
    [ -f "$2" ] && local f2="$2"
    [ "$3" ] && local log_dir="$(dirname $3)" && mkdir -p "$log_dir" && local log="$3"
    # 
    if [ "$f1" -a "$f2" ]; then
        # if 'f1' changed, sync to 'f2' (-nt - newer than, -ot older than)
        [ "$f1" -nt "$f2" ] && local f1_f2=true
        [ "$f2" -nt "$f1" ] && local f2_f1=true
        # 
    elif [ "$f1" -a -z "$f2" ]; then    # create f2, if missing
        local f1_f2=true
    elif [ "$f2" -a -z "$f1" ]; then    # create f1, if missing
        local f2_f1=true
    fi
    if [ "$f1_f2" ]; then
        # set timestamp of original file to target file
        cp --preserve=timestamps "$f1" "$(dirname $2)"
        [ "$log" ] && echo "$(date) synched: \"$f1\" -> \"$2\"" >> "$log"
    # 
    elif [ "$f2_f1" ]; then
        cp --preserve=timestamps "$f2" "$(dirname $1)"
        [ "$log" ] && echo "$(date) synched: \"$f2\" -> \"$1\"" >> "$log"
    fi
    # remove log directory if empty
    [ "$log_dir" ] && [ ! "$(ls "$log_dir")" ] && rmdir "$log_dir"
    return 0
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# run profile() function and remove after execution
profile &&
    unset host pxfile &&
    unset -f profile

# cd to START_DIR if terminal was opened from a context menu or in a particular folder
[ "$START_DIR" ] &&
    builtin cd "$START_DIR" ||
    builtin cd "$HOME"

# sync VSCode 'settings.json' between git-location and $APPDATA location with
# .profile in every new terminal, also with .bash_logout at the end of session,
# where also 'keybindings.json' and 'launch.json' are sync'ed
[ "${PX[APPDATA_CYG]}" ] &&
    sync_files "$HOME/.vscode_global/settings.json" "${PX[APPDATA_CYG]}/Code/User/settings.json" \
        "$HOME/.vscode_global/sync_logs/settings_sync.log"
