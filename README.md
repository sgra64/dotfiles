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
 |
 +--.minttyrc                   # definitions for the mintty terminal (used by cygwin, Gitbash)
 +--.vimrc                      # settings for the 'vim' editor
 |
 +-<.tmux>                      # directory with settings for the 'tmux' terminal multiplexer
 |  +--default.conf             # preset with 2 vertical terminal panel
 |  +--dev2x2.conf              # preset with 2x2 terminal panels
 |  +--tmux.md                  # brief 'tmux' introduction
 |
 +--dotfiles_git.tar            # distribution repository (.git repository)
 +--dotfiles_git.zip
```


## Setup

You can inspect files and choose which ones to use.
You can also use regular checkout into a `dotfiles` folder and
move/copy files to `$HOME`.

Another way is to unpack the `.git` repository directly into
the `$HOME` directory from
[dotfiles_git.tar](dotfiles_git.tar) or
[dotfiles_git.zip](dotfiles_git.zip).

Then, the `$HOME` directory will act like the `dotfiles` repository.
Files can be regularly checked out:

```sh
cd $HOME                    # cd into $HOME, 'dotfiles_git.tar' is assumed there
ls -la dotfiles_git.tar
-rw-r--r-- 1 81920 Oct  6 13:11 dotfiles_git.tar

tar xvf dotfiles_git.tar    # unpack '.git'-repository from tar-file

ls -la                      # show local '.git'-repository
drwxr-xr-x 1 svgr2 Kein     0 Oct  6 13:13 .git

git checkout .              # check-out dotfiles from '.git'-repository

ls -la                      # new dotfiles are present
```
```
-rw-r--r-- 1  3935 Oct  6 13:15 .ansi-colors.sh
-rw-r--r-- 1 12730 Oct  6 13:15 .bashrc
drwxr-xr-x 1     0 Oct  6 13:15 .git/
-rw-r--r-- 1   964 Oct  6 13:15 .gitconfig
-rw-r--r-- 1   515 Oct  6 13:15 .gitignore
-rw-r--r-- 1   376 Oct  6 13:15 .minttyrc
-rw-r--r-- 1  2593 Oct  6 13:15 .paths
-rw-r--r-- 1  5807 Oct  6 13:15 .profile
drwxr-xr-x 1     0 Oct  6 13:15 .tmux/
-rw-r--r-- 1  1056 Oct  6 13:15 .vimrc
-rw-r--r-- 1   360 Oct  6 13:15 .zprofile
-rw-r--r-- 1  4640 Oct  6 13:15 .zshrc
-rw-r--r-- 1  2590 Oct  6 13:15 README.md
```

The local `.git` repository can now be detached from the remote.

```sh
git branch -r -d origin/main    # remove remote branch

git remote rm origin            # remove origin (remote-link)

rm dotfiles_git.*               # remove .tar/.zip
```

Next, enter *name* and *email* for global suer git setting in *.gitconfig*.

```sh
git config --global user.name "your name"
git config --global user.email "your@email.com"
```

Commit changes:

```sh
git add .gitconfig
git commit -m "entered name, email for .gitconfig"
```

Advantage of this method is that *dotfiles* remain under
git control in a local `.git`-repository in `$HOME`.

This is useful for restoring prior versions and evolving
*dotfiles* under own control.
