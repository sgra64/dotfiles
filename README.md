# *dotfiles*

*"Dotfiles"* are files or directories with names that start with a dot `.` hiding them
from regular view. They contain vital setup and configuration information for the system,
shells and other tools. Most *dotfiles* are located in the user's `$HOME` directory.

On most systems, *dotfiles* are *"hidden"* (not visible) in the filesystem by default.
To show them, follow instructions for
[*Mac*](https://www.macworld.com/article/671158/how-to-show-hidden-files-on-a-mac.html) or
[*Windows*](https://support.microsoft.com/en-us/windows/view-hidden-files-and-folders-in-windows-97fbc472-c603-9d90-91d0-1166d1d9f4b5).

*Dotfiles* relevant for login (new terminal) and startup (new shell process) scripts are:
*.profile*, *.zprofile* (Mac), *.bashrc*, *.zshrc* (Mac).

The most prominent definition in *dotfiles* is the
[*$PATH*](https://medium.com/@linuxadminhacks/what-is-the-path-variable-in-linux-and-unix-98267b7432b8)
environment variable, which defines paths to directories with executable commands.
It is often set in *.profile*, *.bashrc* and *.zshrc* files.
Script *.ansi-colors.sh* defines

File *.mintty* has definitions for the
[*mintty*](https://en.wikipedia.org/wiki/Mintty)
terminal emulator used by
[*cygwin*](https://en.wikipedia.org/wiki/Cygwin) and
[*msys*](https://en.wikipedia.org/wiki/Mingw-w64#MSYS2), which is used by
[*Gitbash*](https://gitforwindows.org).

File *.vimrc* contains settings for the
[*vim*](https://www.freecodecamp.org/news/vim-beginners-guide/)
editor.

Directory *.tmux* stores settings for the
[*tmux*](https://www.perl.com/article/an-introduction-to-tmux/)
terminal multiplexer.


```sh
<$HOME>                 # User's home directory
 |
 +--.gitconfig                  # User's global git configuration in $HOME
 +--.gitignore                  # patterns of file and directory names for git to ignore
 +-- README.md                  # this markup file
 | 
 +--.profile                    # bash logon script that runs when a new terminal is opened (Windows, Linux)
 +--.zprofile                   # zsh logon script (Mac)
 +--.bashrc                     # bash process startup script that runs with each new bash process
 +--.bashrc.path                # .bashrc extension with PATH settings
 +--.zshrc                      # zsh startup script that runs with each new zsh process
 |
 +--.minttyrc                   # settings for the mintty terminal emulator (used by cygwin, Gitbash)
 +--.vimrc                      # settings for the 'vim' editor
 |
 +-<.tmux>                      # directory with settings for the 'tmux' terminal multiplexer
 | +--default.conf              # preset with 2 vertical panes
 | +--dev-2x2.conf              # preset with 2x2 panes
 | +--se1-play.conf             # preset with 1x2 panes for the se1-play project
 | +--tmux.md                   # 'tmux' introduction
 |
 +--dotfiles[date]-release-[rel].tar    # .tar archive with dotfile .git release repository
 +--dotfiles[date]-release-[rel].zip    # .zip archive with dotfile .git release repository
```

Terminal appearance and capabilities can be highly customized in dotfiles.

<table>
<td valign="top">
<img src="https://raw.githubusercontent.com/sgra64/dotfiles/refs/heads/markup/img/terminal-HOME.png" width="400"/>
</td>
<td valign="top">
<img src="https://raw.githubusercontent.com/sgra64/dotfiles/refs/heads/markup/img/terminal-git.png" width="400"/>
</td>
</table>

The Terminal to the left shows the *HOME* directory of a user with dotfiles, links and a
`workspaces` folder.
The prompt shows:
the command number `708`,
the user id and machine indicator `svgr2@'X1-Carbon'` (where the shell runs),
the time `14:38` and
the path `~` relative to HOME or `~/workspaces` after changing to this directory.

The Terminal to the right is in "*git-project more*" showing a changed prompt with
project name `[se1-play]` and branch `[main]` (purple) followed by the path `~` (red)
relative to the project directory.

Building and customizing the terminal prompt can be seen in file [*.profile*](.profile).


&nbsp;

## Installing *dotfiles*

### Step 1: Unpack dotfiles *.git* Repository in *$HOME*

In order to install dotfiles, download archive files *dotfiles[date]-release-[rel].{tar,zip}*
to your $HOME directory and unpack:

```sh
cd $HOME                        # cd to $HOME directory
tar xvf dotfiles[date]-release-[rel].tar    # unpack .tar file creating a local .git repository in $HOME

git status                      # test the status of the dotfile git repository
```

Dotfiles already present in $HOME are shown as *modified*, new dotfiles appear as *deleted* (not yet present):

```
On branch main
Changes not staged for commit:
  (use "git add/rm <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
        modified:   .bashrc
        deleted:    .bashrc.path
        deleted:    .gitconfig
        deleted:    .gitignore
        deleted:    .minttyrc
        modified:   .profile
        deleted:    .tmux/default.conf
        deleted:    .tmux/dev-2x2.conf
        deleted:    .tmux/se1-play.conf
        deleted:    .tmux/tmux.md
        deleted:    .vimrc
        deleted:    .zshrc

Untracked files:
  (use "git add <file>..." to include in what will be committed)
        dotfiles250317-release-1.0.9.tar

no changes added to commit (use "git add" and/or "git commit -a")
```


&nbsp;

### Step 2: Check-out *dotfiles*

Dotfiles can be checked out from the local git-repository:

```sh
git checkout .                  # check-out dotfiles

ls -la                          # show files
```

New dotfiles are now in the $HOME directory.

```
total 62
drwxr-xr-x 1     0 Mar 17 22:45 ./
drwxr-xr-x 1     0 Mar 17 21:42 ../
-rw-r--r-- 1  6658 Mar 17 22:45 .bashrc
-rw-r--r-- 1  1909 Mar 17 22:45 .bashrc.path
drwxr-xr-x 1     0 Mar 17 22:45 .git/
-rw-r--r-- 1  1158 Mar 17 22:45 .gitconfig
-rw-r--r-- 1   507 Mar 17 22:45 .gitignore
-rw-r--r-- 1   376 Mar 17 22:45 .minttyrc
-rw-r--r-- 1 17758 Mar 17 22:45 .profile
drwxr-xr-x 1     0 Mar 17 22:45 .tmux/
-rw-r--r-- 1  1056 Mar 17 22:45 .vimrc
-rw-r--r-- 1  1062 Mar 17 22:45 .zshrc
```


&nbsp;

### Step 3: Adjust *dotfiles*

Dotfiles need to be adjusted to your environment.

Git requires name and email configured in `.gitconfig` in your $HOME directory.
Enter your name and email either by commands:

```sh
git config --global user.name "your name"
git config --global user.email "your@email.com"
```

or by editing `.gitconfig` directly:

```sh
# Enter your name and email in the [user] section below either by editing or by
# global git config commands:
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

Adjust paths in `.bashrc.path` depending on your system, for example
the $PATH to the Java JDK:

```sh
# Java installation directory (commands: 'java', 'javac', 'jar', 'javap')
export JAVA_HOME="/c/Program Files/Java/jdk-21"
export PATH="${PATH}:${JAVA_HOME}/bin"
```


&nbsp;

### Step 3: Clean-up and Commit Changes

The initial `dotfiles[date]-release-[rel].tar` is no longer needed as is file
`README.md` that came with the check-out.

Remove these files and commit the changes you made to `.gitconfig` and `.paths`:

```sh
rm dotfiles*.tar                # remove files

git status
```
```
On branch main
Changes not staged for commit:
  (use "git add/rm <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
        modified:   .gitconfig
        modified:   .bashrc.path
```

Commit changes to the local .git repository:

```sh
git add .                           # stage and commit changes
git commit -m "update .gitconfig, .bashrc.path"

git log --oneline                   # show the new commit
```

<!-- 
The last step is to detach the .git repository from its remote source.
You can add your own remote repository.

```sh
git branch -r -d origin/main        # remove the remote branch
git remote remove origin            # remove the remote repository URL

git remote add origin <your url>    # add your own remote repository URL
``` -->
