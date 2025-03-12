
# extend PATH to find UNIX commands
PATH="$PATH:/usr/bin:/bin:/usr/local/bin"

# attempt to locate platform-specific .px file to load PX[] array, e.g. '.bashrc-win-x1.px'
[[ "$HOSTNAME" = "LAPTOP-V50CGD0T" && "$SHELL" =~ bash ]] && \
    px_file=".bashrc-win-x1.px" && [ -f "${HOME}/$px_file" ] || unset px_file

# declare PX[] array or load from px_file
if [ -z "$px_file" ]; then
    declare -gA PX
    PX[LAPTOP-V50CGD0T]="X1-Carbon" # map hostname to alias HOSTNAME used in prompt
    PX[X1-Carbon]="win-x1"          # map alias to 'ext' in '.profile-{ext}' for setting PATH
    # 
    PX[clean-envar]="true"          # clean environment variables
    PX[has-color]=""                # terminal has colors: true or false
    PX[color]=""                    # current color setting: 'on' or 'off'
    PX[term]=""                     # alternate TERM setting to color 'on' or 'off'
    PX[has-git]=""                  # git is installed
    PX[has-realpath]=""             # realpath command is present
    PX[has-cygpath]=""              # cygpath command is present
    PX[git-project-name]=""         # name of current git project or ""
    PX[bashrc-ext]=""               # platform-specific .bashrc extension file, e.g. '.bashrc-win-x1'
    # 
    PX[ps1-color]=""                # patterns for PS1 command line prompts
    PX[ps1-mono]=""
    PX[ps1-git-color]=""
    PX[ps1-git-mono]=""
    PX[ls-colors]=""                # settings for LS_COLORS environment variable
    #                               # remove files from $HOME
    PX[home-cleanup]=".bash_history .lesshst .zsh_history .cache .vim "
    PX[declared]="true"             # mark PX as declared
else
    export PX_EXPORT="$(cat ${HOME}/$px_file)"
    declare -A PX="${PX_EXPORT#*=}"
    PX[declared]=""                 # mark PX as not declared
    PX[color]=""                    # reset color to force setting in color()
fi

PX[log]=""                          # enable logging with setting any value
# 
if [ "${PX[log]}" ]; then
    [ "${PX[declared]}" = true ] && echo "declared PX[]" || echo "loaded PX[] from $px_file"
fi


function setup_profile() {
    [ "${PX[log]}" ] && echo -n ".profile"
    # 
    # locating commands from existing PATH
    local path_ext=""
    for cmd in git realpath cygpath code powershell; do
        p=$(which "$cmd" 2>/dev/null)
        case "$p" in
        */realpath)     PX[has-realpath]="true" ;;
        */cygpath)      local has_cygpath="true" ;;
        */git)          PX[has-git]="true"; path_ext+=":"$(/usr/bin/dirname "$p") ;;
        */code)         path_ext+=":"$(/usr/bin/dirname "$p") ;;
        */powershell)   path_ext+=":"$(/usr/bin/dirname "$p") ;;
        esac
    done
    # 
    export PATH=".:/usr/local/bin:/usr/bin:/bin""$path_ext"

    [ "$has_cygpath" = true -a "$START_DIR" ] && \
        export START_DIR=$(cygpath "${START_DIR//\"/}")

    # Windows: clean-up environment, 'OS' only exists on Windows
    if [[ "$OS" && "$OS" =~ Windows ]]; then
        if [ "${PX[clean-envar]}" = "true" ]; then
            # remove environment variables inherited from Windows, except those in match patterns
            local remove=()
            for v in $(sed -e 's/=.*//' <<< $(env)); do
                # cannot unset strange var: 'ProgramFiles(x86)' 'CommonProgramFiles(x86)' '!::', '_'
                [[ "$v" =~  (ProgramFiles.x86.|^!::$|^_$) ]] && continue
                # keep these variables, PROFILEREAD is read-only with zsh and can't be unset
                [[ "$v" =~ ^(START_DIR|PATH|HOME|SHELL|TERM|OSTYPE|USERPROFILE|SYSTEMROOT|PROFILEREAD)$ ]] && \
                    continue
                remove+=($v)
            done
            # remove all other environment variables inherited from Windows
            [[ ${#remove[@]} -gt 0 ]] && unset ${remove[@]}
        fi
        export USER="$(/usr/bin/id -un)"    # alt: USER=$(whoami)
        export LANG=$(/usr/bin/locale -uU)
        # 
        # ignore Windows \r line ends, otherwise error: '\r': command not found in .bashrc
        (set -o igncr) 2>/dev/null && set -o igncr;
        # 
        # change Windows default code page (437) to UTF-8 (65001), see:
        # https://superuser.com/questions/269818/change-default-code-page-of-windows-console-to-utf-8/269857#269857
        $(cygpath ${SYSTEMROOT})/system32/chcp.com 65001 &>/dev/null
    fi
    # 
    local host="$(hostname)"   # attempt to map 'hostname'
    [ "$host" -a "${PX[$host]}" ] && host="${PX[$host]}"
    # 
    export HOSTNAME="$host"
    [ -z "$LANG" ] && export LANG="en_US.UTF-8"
    [ -z "$SHELL" ] && \
        export SHELL="$(ps -p $$ | sed -e '/PID/d' -e 's/.* //g')"
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
            export LC_COLLATE="C"      # show dotfiles first and not merged for 'ls'-list (as WSL:Ubuntu does)
            ;;
    esac

    # - - - - - - - - - - - -
    [ "${PX[declared]}" = true ] && \
        build_colors

    export LS_COLORS="${PX[ls-colors]}"

    # locate platform-specific .bashrc extension file, e.g. '.bashrc-win-x1'
    [ "$HOSTNAME" -a "${PX[$HOSTNAME]}" ] && \
        PX[bashrc-ext]=".bashrc-"$(/usr/bin/tr '[A-Z]' '[a-z]' <<< "${PX[$HOSTNAME]}") && \
        [ -f "${HOME}/${PX[bashrc-ext]}" ] || PX[bashrc-ext]=""
    # 
    # bash does not run ~/.bashrc implicitely
    [[ "$SHELL" =~ bash && -f "${HOME}/.bashrc" ]] && \
            builtin source "${HOME}/.bashrc" LOGIN
    # 
    return 0
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# include coloring functions only when PX[] was declared and needs values computed
if [ "${PX[declared]}" = true ]; then
    #
    function build_colors() {
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

        PX[ls-colors]=$(colorize_ls_colors \
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
    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# 
fi

setup_profile && \
    unset -f setup_profile

[ "$START_DIR" ] && \
    builtin cd "$START_DIR" || \
    builtin cd "$HOME"

# unset coloring functions that are no longer needed
[ "${PX[declared]}" = true ] && \
    unset -f ansi_code colorize_prompt colorize_ls_colors || unset px_file
