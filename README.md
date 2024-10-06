# dotfiles

*"Dotfiles"* are files or directories with names that start with a dot `.`
and contain vital setup and configuration information for the system and
for tools. Most *dotfiles* are stored in the user's `$HOME` directory.

Prominent *dotfiles* are:
[*.profile*](),
[*.zprofile*]() (Mac),
[*.bashrc*](),
[*.zshrc*]() (Mac)
for executing commands upon login (when a terminal is opened) (*.profile*)
or when a new Shell process starts (*.bashrc* for *bash* and *.zshrc* for *zsh*).

On most systems, *dotfiles* are *"hidden"* (not visible) in the filesystem by
default. To show them, follow instructions for
[*Mac*](https://www.macworld.com/article/671158/how-to-show-hidden-files-on-a-mac.html) or
[*Windows*](https://support.microsoft.com/en-us/windows/view-hidden-files-and-folders-in-windows-97fbc472-c603-9d90-91d0-1166d1d9f4b5).

The first commit includes the .gitignore file.

```sh
<$HOME>                 # User's home directory
 |
 +--.gitconfig                  # User's git configuration in $HOME
 +--.gitignore                  # patterns of file and directory names for git to ignore
 +-- README.md                  # this markup file
```
