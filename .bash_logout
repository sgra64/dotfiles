#!/bin/bash
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# .bash_logout is executed when login bash process is terminated, not at the
# end of shell sub-processes.
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# 

# sync VSCode 'settings.json', 'keybindings.json' and 'launch.json' between
# git-location and $APPDATA location at .bash_logout at the end of session
[ "${PX[APPDATA_CYG]}" ] &&
    for f in settings keybindings launch; do
        sync_files  "$HOME/.vscode_global/$f.json" "${PX[APPDATA_CYG]}/Code/User/$f.json" \
            "$HOME/.vscode_global/sync_logs/${f}_sync.log"
    done

# reset history
rm -f .bash_history .zsh_history && history -c
