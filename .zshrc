# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

echo ".zshrc"

HOSTNAME_ALIAS="laptop"   # $(hostname)

function build_aliases() {
    # 
    alias c="clear"
    alias aliases="alias"
    alias vi="vim"              # use vim for vi, -u ~/.vimrc
    alias ls="/bin/ls"          # colorize ls output
    alias l="ls -alFog"         # detailed list with dotfiles
    alias ll="ls -l"            # detailed list with no dotfiles
    alias grep="grep"
    alias egrep="egrep"
    alias pwd="pwd -LP"         # show real path with resolved links
    alias path="echo \$PATH | tr ':' '\012'"
    [ "$MAVEN_HOME" ] && \
        alias mvn="$MAVEN_HOME/bin/mvn $mvn_mono"   # -B: color off
    # 
    # set useful git aliases
    #  - prune, https://stackoverflow.com/questions/2116778/reduce-git-repository-size
    alias gt="git status" && \
    alias log="git log --oneline" && \
    alias br="git branch -avv" && \
    alias prune="git reflog expire --expire=now --all; git gc --prune=now --aggressive" && \
    alias gar="[ -d .git ] && tar cvf $(date '+%y-%m%d-git.tar') .git || echo 'no .git directory'"

    function env() {    # show environment variables
        [[ "$1" == "--names" ]] && /usr/bin/env | sed -e 's/=.*//' && return
        [[ "$1" ]] && \
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
    function rp() {     # show realpath of $1
        [[ "$1" ]] && realpath $* || realpath .
    }
    function his() {      # list history commands, select by $1
        [[ "$1" == "--all" ]] && history | uniq -f 1 && return
        [[ "$1" ]] && history | grep $1 | uniq -f 1 || history | tail -40
    }
    function functions() {  # list functions by name or specific function
        print -l ${(ok)functions}
    }
}

function build_prompt() {
    # PROMPT=$(colorize_prompt true "${reg_prompt[@]}")
    # PROMPT=$'%{\e[32m%}> \u \h %{\e[0m%}'
    # PROMPT="%F{green}hi>%f "
    # https://stackoverflow.com/questions/30199068/zsh-prompt-and-hostname
    # https://stackoverflow.com/questions/57469946/dark-grey-background-color-in-zsh-using-autoload
    autoload -U colors && colors
    PS1="%{$fg[green]%}"
    PS1+="%! "                      # history number
    PS1+="%n@'${HOSTNAME_ALIAS}'"   # username from env variable
    PS1+="%{$fg[white]%}"
    PS1+=" (%T)"                    # time
    # 
    PS1+=" %{$fg_bold[yellow]%}"    # path in bright yellow
    PS1+="%~ "                      # show current path relative to ~
    # 
    # PS1+=$'\e[1;33m '               # bright yellow in ANSI ESC spoils line end control
    # PS1+="%~ "                      # show current path relative to ~
    # PS1+=$'\e[0m'                   # reset coloring, spoils line end control
    # PS1+=$'\[\e[0m\]'
    # 
    PS1+="%{$reset_color%}%"
    PS1+=" > "
}

source .paths
build_aliases
build_prompt

# otherwise, commands like: wc $(find tmp -name '*.py') ill-process first line
trap "" DEBUG

## History file configuration
# https://github.com/ohmyzsh/ohmyzsh/blob/master/lib/history.zsh
HISTFILE="$HOME/.zsh_history"
HISTSIZE=5000
SAVEHIST=1000

## History command configuration
setopt extended_history       # record timestamp of command in HISTFILE
setopt hist_expire_dups_first # delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt hist_ignore_dups       # ignore duplicated commands history list
setopt hist_ignore_space      # ignore commands that start with space
setopt hist_verify            # show command with history expansion to user before running it
setopt share_history          # share command history data


# cd ~

# macOS: use uname -s (not -o), see: https://www.unix.com/man-page/osx/1/uname
# case $(uname -s) in
#     # run .profile on Windows
#     # CYGW*) local ZSH=true; [ -f .profile ] && source .profile ;;
#     CYGW*) [ -f .bashrc ] && source .bashrc "Win:ZSH" ;;
# esac
# run .bashrc
# [ -f .bashrc ] && source .bashrc $([ "$WINDIR" ] && echo "Win:ZSH" || echo "Mac:ZSH")
