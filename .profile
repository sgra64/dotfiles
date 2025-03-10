
declare -gA PX
PX[LAPTOP-V50CGD0T]="X1-Carbon" # map hostname to alias HOSTNAME used in prompt
PX[X1-Carbon]="win-x1"          # map alias to 'ext' in '.profile-{ext}' for setting PATH
PX[clean-envar]="true"          # clean environment variables
PX[has-color]=""                # terminal has colors: true or false
PX[color]=""                    # current color setting: 'on' or 'off'
PX[log]=""                      # logging setting: 'on' or 'off'
PX[has-git]=""                  # git is installed
PX[has-realpath]=""             # realpath command is present
PX[has-cygpath]=""              # cygpath command is present
PX[git-project-name]=""         # name of current git project or ""
# 
PX[ps1-color]=""                # patterns for PS1 command line prompts
PX[ps1-mono]=""
PX[ps1-git-color]=""
PX[ps1-git-mono]=""
# 
PX[home-cleanup]=".bash_history .lesshst .zsh_history .cache .vim "


function setup_profile() {
    [ "${PX[log]}" ] && echo -n ".profile"

    PATH+=":/usr/local/bin:/usr/bin:/bin"
    # 
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

    [ "${PX[has-realpath]}" = true -a "$HOME" ] && \
        export HOME="$(realpath $HOME)"

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
                # 
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
    # remove write permission for group and others (files are normally created
    # with mode 777 become 755; files created with mode 666 become 644)
    umask 022

    # - - - - - - - - - - - -
    case "$OSTYPE" in
    cygwin) ;;  # Windows, cygwin emulator
    msys)   ;;  # Windows, mingw emulator used for GitBash

    # Ubuntu Linux, 'linux-gnu'
    linux*)
            export LC_COLLATE="C"      # show dotfiles first and not merged for 'ls'-list (as WSL:Ubuntu does)
            ;;
    esac

    case "$SHELL" in
    *bash)
        # 
        # bash does not run ~/.bashrc by itself
        if [ -f "${HOME}/.bashrc" ]; then
            [ "${PX[log]}" ] && echo -n " -> "
            builtin source "${HOME}/.bashrc" LOGIN
        fi
    esac
    # 
    # set PATH from file '.profile-{ext}' first, if present
    [ "$HOSTNAME" -a "${PX[$HOSTNAME]}" ] && \
    local profile_ext=".profile-"$(/usr/bin/tr '[A-Z]' '[a-z]' <<< "${PX[$HOSTNAME]}") && \
    [ -f "${HOME}/$profile_ext" ] && builtin source "${HOME}/$profile_ext"
}


setup_profile && \
    unset -f setup_profile

[ "$START_DIR" ] && \
    builtin cd "$START_DIR" || \
    builtin cd "$HOME"
