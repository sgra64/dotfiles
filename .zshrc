[ "${PX[log]}" ] && echo -n " -> .zshrc" && bashrclog=" -> .bashrc"

# source color control functions for ANSI terminals
[ -f "$HOME/.bashrc" ] && \
    source "$HOME/.bashrc" $bashrclog && \
    unset bashrclog

# autoload -Uz compinit
# compinit
# End of lines added by compinstall
# macOS: use uname -s (not -o), see: https://www.unix.com/man-page/osx/1/uname


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
