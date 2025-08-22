# .bash_logout is executed when login bash process is terminated.

if [ "${PX[APPDATA_CYG]}" ]; then
    # 
    # sync VSCode 'settings.json', 'keybindings.json' and 'launch.json' between
    # git-location and $APPDATA location, write logs
    for f in settings keybindings launch; do
        sync_files "$HOME/.vscode_global/$f.json" "${PX[APPDATA_CYG]}/Code/User/$f.json" \
            "$HOME/.vscode_global/${f}_sync.log"
    done
fi
