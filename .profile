# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# shell executes in order:
# - bash:
#   - /etc/profile
#   - /etc/bash.bashrc
#   - .profile
#   - .bashrc (sourced in .profile)
# - zsh:
#   - .zprofile calls --> .profile
#   - .zshrc calls --> .bashrc
# 
# TERM=xterm-256color
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

echo ".profile"

# umask 022 permissions of new files are 644 (files) and 755 (directories)
umask 022

# set LANG environment variable (otherwise git may print German messages)
LANG=en_US.UTF-8

# source this file when entering directory of a git project
ENV_SH=".env.sh"

# show dotfiles first and not merged for 'ls'-list (as WSL:Ubuntu does)
LC_COLLATE="C"

# map hostname to nicer looking alias
HOSTNAME=$(hostname)
case "$HOSTNAME" in
    LAPTOP-V50CGD0T)    HOSTNAME_ALIAS="X1-Carbon" ;;
esac

case $(uname -s) in
    # 
    CYGW*|MINGW*)
        SYS=$1       # set "Win:ZSH" or "Mac:ZSH" passed from .zprofile
        [ "$MSYSTEM" ] && SYS="Win:MINGW"    # set as GitBash mingw
        [ -z "$SYS" ] && SYS="Win:CYGWIN"    # otherwise, set for cygwin
        # 
        function env_Windows() {
            # set/reset environment variables coming from Windows
            USER=$(whoami)       # reset $USERID
            USERNAME=${USER}     # reset $USERNAME
            HOME=$(realpath $HOME)   # resolve linked $HOME
            PWD=$HOME    # used by '\w' in PS1 prompt string
            # 
            # except for zsh, remove unessesary environment variables inherited from Windows
            if [[ ! "$SYS" =~ .*ZSH ]]; then
                # remove environment variables, except those in 'keep'-array
                local keep=(
                    LANG ENV_SH LC_COLLATE HOSTNAME HOSTNAME_ALIAS SYS PATH USER USERNAME HOME PWD
                    HAS_GIT START_DIR TERM USERPROFILE SYSTEMROOT PROFILEREAD _
                    "ProgramFiles" "CommonProgramFiles(x86)" "!::"
                    # APPDATA LOCALAPPDATA SHELL
                )
                local remove=""
                for ev in $(sed -e 's/=.*//' <<< $(env)); do
                    [[ "${keep[@]}" =~ "$ev" ]] || \
                        remove+="$ev "
                done
                unset $remove
                # 
                # remove unwanted inherited functions, e.g. gawklibpath_append, etc.
                keep=(env_Windows)
                remove=""
                for f in $(sed -e 's/declare -f //' <<< $(declare -F)); do
                    [[ "${keep[@]}" =~ "$f" ]] || \
                        remove+="$f "
                done
                unset -f $remove
            fi
            # cygify Windows path to start directory passed in START_DIR environment variable
            # IFS: disables spaces being treated as field separators in cygpath
            [ "$START_DIR" ] && IFS=@ && \
                START_DIR=$(cygpath $(tr -d '"' <<< "$START_DIR")) && \
                unset IFS

            # ignore Windows \r line ends, otherwise error: '\r': command not found in .bashrc
            (set -o igncr) 2>/dev/null && set -o igncr;
            # 
            # change Windows default code page (437) to UTF-8 (65001), see:
            # https://superuser.com/questions/269818/change-default-code-page-of-windows-console-to-utf-8/269857#269857
            $(cygpath ${SYSTEMROOT})/system32/chcp.com 65001 &>/dev/null
        }
        env_Windows             # call env_Windows() function
        unset -f env_Windows    # remove env_Windows() function
        ;;
    # 
    *Linux)
        SYS="Linux"
        PATH=".:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
        [ "$WSL_DISTRO_NAME" = "Ubuntu" ] && \
            SYS="WSL:Ubuntu" && \
            [ -f ~/.bashrc ] && source ~/.bashrc
        ;;
    # 
    *) echo '~/.profile: $(uname -s) unmatched' ;;
esac

# source script to build PATH variable
[ -f ~/.paths ] && \
    source ~/.paths "$SYS"

# test git is installed (except for .zsh), HAS_GIT: true, false
[ -z "$HAS_GIT" ] && \
    HAS_GIT=$(git --version >/dev/null 2>/dev/null; [[ $? = 0 ]] && echo true || echo false)

# bash does not automatically run .bashrc with new terminal (zsh runs .zshrc)
[ -f ~/.bashrc ] && \
    source ~/.bashrc

# export environment variables to be effective in sub-processes
export LANG ENV_SH LC_COLLATE HOSTNAME HOSTNAME_ALIAS SYS \
        PATH USER USERNAME HOME PWD HAS_GIT
