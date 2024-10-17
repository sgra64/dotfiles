# *dotfiles*

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
 | +--default.conf              # preset with 2 vertical terminal panel
 | +--dev2x2.conf               # preset with 2x2 terminal panels
 | +--tmux.md                   # brief 'tmux' introduction
 |
 +--dotfiles_git.tar            # .tar archive with dotfile .git repository
 +--dotfiles_git.zip            # .zip archive
```


&nbsp;

## Installing *dotfiles*

### Step 1: Install local dotfile *.git* Repository

In order to install dotfiles, fetch
[dotfiles_git.tar](https://raw.githubusercontent.com/sgra64/dotfiles/refs/heads/main/dotfiles_git.tar) or
[dotfiles_git.zip](https://raw.githubusercontent.com/sgra64/dotfiles/refs/heads/main/dotfiles_git.zip)
and un-tar or unzip in the $HOME directory.

```sh
cd $HOME                        # cd to $HOME directory
tar xvf dotfiles_git.tar        # unpack .tar file creating local .git repository in $HOME

git status                      # test status of dotfile git repository
```

Dotfiles that are already present in $HOME are shown as *modified*,
new dotfiles appear as *deleted* (not yet present)).

```
On branch main
Your branch is ahead of 'origin/main' by 2 commits.
  (use "git push" to publish your local commits)

Changes not staged for commit:
  (use "git add/rm <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
        deleted:    .ansi-colors.sh
        modified:   .bashrc
        deleted:    .gitconfig
        deleted:    .gitignore
        deleted:    .minttyrc
        deleted:    .paths
        modified:   .profile
        deleted:    .tmux/default.conf
        deleted:    .tmux/dev2x2.conf
        deleted:    .tmux/tmux.md
        deleted:    .vimrc
        deleted:    .zprofile
        deleted:    .zshrc
        deleted:    README.md

Untracked files:
  (use "git add <file>..." to include in what will be committed)
        dotfiles_git.tar

no changes added to commit (use "git add" and/or "git commit -a")
```


&nbsp;

### Step 2: Check-out *dotfiles*

Dotfiles can be checked out from the local git-repository:

```sh
git checkout .                  # check-out dotfiles

ls -la                          # show files
```

New dotfiles are now in the $HOME directory and effective immetiately.

```
total 151
drwxr-xr-x 1     0 Oct 18 00:03 ./
drwxr-xr-x 1     0 Oct 17 23:57 ../
-rw-r--r-- 1  3935 Oct 18 00:03 .ansi-colors.sh
-rw-r--r-- 1 13939 Oct 18 00:03 .bashrc
drwxr-xr-x 1     0 Oct 18 00:03 .git/
-rw-r--r-- 1   964 Oct 18 00:03 .gitconfig
-rw-r--r-- 1   516 Oct 18 00:03 .gitignore
-rw-r--r-- 1   376 Oct 18 00:03 .minttyrc
-rw-r--r-- 1  4384 Oct 18 00:03 .paths
-rw-r--r-- 1  4462 Oct 18 00:03 .profile
drwxr-xr-x 1     0 Oct 18 00:03 .tmux/
-rw-r--r-- 1  1056 Oct 18 00:03 .vimrc
-rw-r--r-- 1   360 Oct 18 00:03 .zprofile
-rw-r--r-- 1  4640 Oct 18 00:03 .zshrc
-rw-r--r-- 1  2590 Oct 18 00:03 README.md
-rw-r--r-- 1 81920 Oct 17 23:58 dotfiles_git.tar
```


&nbsp;

### Step 3: Update *dotfiles*

Dotfiles need to be adjusted to your environment.

Git requires name and email configured in `.gitconfig` in your $HOME
directory. Enter your name and email either by commands:

```sh
git config --global user.name "your name"
git config --global user.email "your@email.com"
```

or by editing `.gitconfig` directly:

```sh
# must spefify your name:
# - git config --global user.name "your name"
# - git config --global user.email "your@email.com"
# [user]
#   name = Sven Graupner
#   email = sgraupner@bht-berlin.de
[user]
    name = your first and last name
    email = your email address

# leave other parts unchanged
```

Adjust paths in `.paths` depending on your system, for example
the $PATH to the Java JDK:

```sh
# Java installation directory (commands: 'java', 'javac', 'jar', 'javap')
export JAVA_HOME="/c/Program Files/Java/jdk-21"
export PATH="${PATH}:${JAVA_HOME}/bin"
```


&nbsp;

### Step 3: Clean-up and Committing Changes

The initial `dotfiles_git.tar` is no longer needed as is `README.md` that
came with the check-out.

Remove these files and commit changes made to `.gitconfig` and `.paths`:

```sh
rm dotfiles_git.* README.md         # remove files

git status
```
```
On branch main
Changes not staged for commit:
  (use "git add/rm <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
        modified:   .gitconfig
        modified:   .paths
        deleted:    README.md
```

Commit changes back to the local .git repository:

```sh
git add .                           # stage and commit changes
git commit -m "update .gitconfig, .paths"
```

The last step is to detach the .git repository from its remote source.
You can add your own remote repository.

```sh
git branch -r -d origin/main        # remove remote branch
git remote remove origin            # remove remote repository URL

git remote add origin <your url>    # add your own remote repository URL
```
