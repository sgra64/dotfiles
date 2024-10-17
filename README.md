# dotfiles

*"Dotfiles"* are files or directories with names that start with a dot `.`
and contain vital setup and configuration information for the system and
for tools. Most *dotfiles* are stored in the user's `$HOME` directory.

On most systems, *dotfiles* are *"hidden"* (not visible) in the filesystem by
default. To show them, follow instructions for
[*Mac*](https://www.macworld.com/article/671158/how-to-show-hidden-files-on-a-mac.html) or
[*Windows*](https://support.microsoft.com/en-us/windows/view-hidden-files-and-folders-in-windows-97fbc472-c603-9d90-91d0-1166d1d9f4b5).

Login (new terminal) and startup (new shell process) scripts are:
*.profile*, *.zprofile* (Mac), *.bashrc*, *.zshrc* (Mac).

Script *.paths* includes definitions for the
[*$PATH*](https://medium.com/@linuxadminhacks/what-is-the-path-variable-in-linux-and-unix-98267b7432b8)
environment variable. It is used by *.bashrc* and *.zshrc*.
Script *.ansi-colors.sh* defines
[*ANSI Color Codes*](https://gist.github.com/fnky/458719343aabd01cfb17a3a4f7296797)
for colored prompt and terminal output.

File *.mintty* has definitions for the mintty terminal (used by cygwin, Gitbash).
File *.vimrc* contains settings for the
[*vim*](https://www.freecodecamp.org/news/vim-beginners-guide/)
editor.

Directory *.tmux* stores settings for the
[*tmux*](https://www.perl.com/article/an-introduction-to-tmux/)
terminal multiplexer.


```sh
<$HOME>                 # User's home directory
 |
 +--.gitconfig                  # User's git configuration in $HOME
 +--.gitignore                  # patterns of file and directory names for git to ignore
 +-- README.md                  # this markup file
 | 
 +--.profile                    # bash login script (Windows, Linux)
 +--.zprofile                   # zsh login script (Mac)
 +--.bashrc                     # bash startup script (runs with new bash process)
 +--.zshrc                      # zsh startup script (runs with new zsh process)
 +--.paths                      # PATH definitions (used by .bashrc, .zshrc)
 +--.ansi-colors.sh             # ANSI color codes for colored prompt and terminal output
```
