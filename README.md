# *dotfiles*

*"Dotfiles"* are files, folders or directories with names that start with a
dot `.` making those files hidden from regular views. *Dotfiles* contain
settings and configuration information for shells, applications and tools.
Many *dotfiles* are located in the user's `$HOME` directory.

Since *dotfiles* are *"hidden"* (not visible) in the filesystem by default,
follow instructions to expose them for
[*Mac*](https://www.macworld.com/article/671158/how-to-show-hidden-files-on-a-mac.html)
or
[*Windows*](https://support.microsoft.com/en-us/windows/view-hidden-files-and-folders-in-windows-97fbc472-c603-9d90-91d0-1166d1d9f4b5).

Most prominent *dotfiles* in the user's `$HOME` directory are *.profile*,
*.zprofile* (Mac), *.bashrc* and *.zshrc* (Mac). Instructions in those files are
executed on *"login"* (when a new terminal is opened) or on *"startup"* (when a
new shell process starts).

An important environment variable defined in those *dotfiles* is the
[*$PATH*](https://medium.com/@linuxadminhacks/what-is-the-path-variable-in-linux-and-unix-98267b7432b8)
variable, which holds a list of paths to directories with executable programs
or commands. Path entries are separated by `:` (on Windows: `;`).
The *PATH* variable is often set in *.profile*, *.bashrc* or *.zshrc*.
It is called an *"environment variable"* since it is defined with a *name*
(*"PATH"*) and a *value* (e.g.: *"/bin:/usr/bin"*) in the *"environment"*
of the process executing a program. Environment variables can be accessed by
programs and are often used to avoid hard-coding configuration information
in programs.

Specific *dotfiles* provide information for specific programs. For example,
*dotfile* *.mintty* has definitions for the
[*mintty*](https://en.wikipedia.org/wiki/Mintty)
terminal emulator that is used by Unix emulators
[*cygwin*](https://en.wikipedia.org/wiki/Cygwin) and
[*msys*](https://en.wikipedia.org/wiki/Mingw-w64#MSYS2) (*msys* is used by
[*Gitbash*](https://gitforwindows.org)).

File *.vimrc* contains settings for the
[*vim*](https://www.freecodecamp.org/news/vim-beginners-guide/)
editor.

Directory *.tmux* stores settings for the
[*tmux*](https://www.perl.com/article/an-introduction-to-tmux/)
terminal multiplexer.

Content of this repository's dotfiles is:

```sh
<$HOME>                 # User's home directory
 |
 +--.gitconfig                  # User's global git configuration settings in $HOME
 +--.gitignore                  # file and directory names to ignore by git
 | 
 +--.profile                    # bash logon script that runs when a new terminal is opened (Windows, Linux)
 +--.zprofile                   # zsh logon script that runs when a new terminal with 'zsh' is opened (Mac)
 +--.bashrc                     # bash process startup script that runs when a new bash process is created
 +--.bashrc.path                # .bashrc extension with platform-specific PATH settings
 +--.bash_logout                # script executed on 'exit'/logout from a bash process
 +--.zshrc                      # zsh startup script that runs when a new zsh process is created
 |
 +--.minttyrc                   # settings for the 'mintty' terminal emulator (used by cygwin, Gitbash)
 +--.vimrc                      # settings for the 'vim' text editor
 |
 +-<.vscode_global>             # directory with system-wide settings for the 'VSCode' IDE
 | +--settings.json             # file where VSCode stores global settings
 | +--launch.json               # file with global launch configurations
 | +--keybindings.json          # file with global keybindings
 |
 +-<.tmux>                      # directory with settings for the 'tmux' terminal multiplexer
 | +--default.conf              # preset with 2 vertical panes
 | +--dev-2x2.conf              # preset with 2x2 panes
 | +--se1-play.conf             # preset with 1x2 panes for the se1-play project
 | +--tmux.md                   # 'tmux' introduction
 |
 +-<.ssh>                       # directory with user's public/private keys
 | +--id_rsa.pub                # user's public key file
 | +--id_rsa                    # user's private key file
```

Terminal appearance and capabilities can be customized in dotfiles.

<table>
<td valign="top">
<img src="https://raw.githubusercontent.com/sgra64/dotfiles/refs/heads/markup/img/terminal-HOME.png" width="400"/>
</td>
<td valign="top">
<img src="https://raw.githubusercontent.com/sgra64/dotfiles/refs/heads/markup/img/terminal-git.png" width="400"/>
</td>
</table>

The Terminal to the left shows the *HOME* directory of a user with dotfiles,
links and a `workspaces` folder.
The prompt shows: the command number `708`, the user id and machine indicator
`svgr2@'X1-Carbon'` (where the shell runs),
the time `14:38` and the path `~` relative to HOME or `~/workspaces` after
changing to this directory.

The Terminal to the right is in "*git-project more*" showing a changed prompt
with project name `[se1-play]` and branch `[main]` (purple) followed by the
path `~` (red) relative to the project directory.

Building and customizing the terminal prompt can be seen in file [*.profile*](.profile).



&nbsp;

## Putting *dotfiles* under *git* Control

*Dotfiles* contain important information and should be kept under version
control (*git*) such that changes can be tracked and recovered and are
backed-up.

You should have your own *git* repository where you keep your *dotfiles*.

Creating a *git* repository for *dotfiles* has several steps:

1. Open a terminal and check you are in your $HOME directoy:

    ```sh
    cd $HOME                    # change to $HOME directory
    pwd                         # show path to $HOME directory
    ```
    ```
    /c/home/svgr                ; path to your $HOME directory
    ```

1. Create an empty *git* repository in your $HOME directoy:

    ```sh
    git --version               # check you have git installed and on the PATH

     # set 'main' as default branch (replacing 'master'), command will add an entry
     # to or create (if not present) the '.gitconfig' dotfile in $HOME
    git config --global init.defaultBranch main

    git init                    # initialize empty git-repository in $HOME directory
    ls -la                      # show new .git-repository as new entry: '.git'

     # create an empty root commit and label as 'root'
    git commit --allow-empty -m "root commit (empty)"
    git tag root
    git log --oneline           # show commit log with empty root commit 
    ```
    ```
    5c14235 (HEAD -> main, tag: root) root commit (empty)
    ```

1. Create files [*.gitignore*](https://github.com/sgra64/dotfiles/blob/main/.gitignore)
    and [*.gitconfig*](https://github.com/sgra64/dotfiles/blob/main/.gitconfig)
    and commit to local *main* branch

    ```sh
    touch .gitignore            # create empty '.gitignore' file

     # open file '.gitignore' with editor and add content or fetch content from
     # the remote 'demo-dot' repository:
    git remote add demo-dot https://github.com/sgra64/dotfiles.git
    git fetch demo-dot main     # fetch 'main' branch from 'demo-dot' repository

     # checkout files '.gitignore', '.gitconfig' from 'demo-dot' repository
    git checkout remotes/demo-dot/main .gitignore .gitconfig

     # pass your name and email to '.gitconfig' file
    git config --global user.name "Your Name"
    git config --global user.email "Your E-Mail"

     # commit both files to local 'main' branch
    git add .gitignore .gitconfig
    git commit -m "add .gitignore, .gitconfig"

    git log --oneline           # show commit log with now two commits
    ```
    ```
    93dcb83 (HEAD -> main) add .gitignore, .gitconfig
    5c14235 (tag: root) root commit (empty)
    ```

More local *dotfiles* from the *HOME* directory can be committed to the local
*main* branch. Examples are: *.profile*, *.bashrc*, *.zshrc* (Mac), etc.



&nbsp;

## Push *main* branch to Your Remote *dotfiles* Repository

In order to push the local *main* branch to your remote *dotfiles* repository,
you must create a remote repository at a remote *git* server where you have an
account.

1. Log into your account in
[*Github.com*](https://github.com/) or
[*BHT Gitlab*](https://gitlab.bht-berlin.de/)
or any other *git* server and create a new, empty project with name *dotfiles*.
Don't add *.gitignore*, *README.md* or other files.

1. Add the URL of the new project as new remote to your local *git* repository
and push the local branch 'main' to the remote branch 'origin/main':

    ```sh
     # add URL as "new remote with name origin" to the local git repository
     # replace "git@gitlab..." with your URL
    git remote add origin git@gitlab.bht-berlin.de:s00000/dotfiles.git

     # attempt to push local branch 'main' to remote
    git push --set-upstream origin main

     # if the push attempt fails with "Updates were rejected because the tip
     # of your current branch is behind its remote counterpart", you need to
     # synchronize the remote branch 'origin/main' with the local branch 'main'

     # only then, perform the "pull" and "commit" steps:
    git pull origin main \
        --squash \
        --allow-unrelated-histories \
        --strategy-option=ours
    ```
    ```
    From git@gitlab.bht-berlin.de:s00000/dotfiles
    * branch            main       -> FETCH_HEAD
    Squash commit -- not updating HEAD
    Automatic merge went well; stopped before committing as requested
    ```

    ```sh
    git status                  # show changes to commit (green lines)

     # commit the merge if there are changes to commit
    git commit -m "initial merge 'origin/main' with local branch 'main'"

    git log --oneline           # show new commit log with now two commits
    ```
    ```
    9919bab (HEAD -> main) initial merge 'origin/main' with local branch 'main'
    93dcb83 add .gitignore, .gitconfig
    5c14235 (tag: root) root commit (empty)
    ```

1. Verify the local branch 'main' is correctly linked to the remote branch
    'origin/main' as *"tracking branch"* ('main') and *"tracked branch"*
    ('origin/main'):

    ```sh
    git branch -avv             # show full branch information
    ```
    <!-- ```
    * main              a63eb24 [origin/main] Merge branch 'main' of gitlab.bht-berlin.de:s00000/dotfiles
    remotes/origin/main a63eb24 Merge branch 'main' of gitlab.bht-berlin.de:sgraupner/demo-dot
    ``` -->

    Output shows for the local *main* branch a marker: `[origin/main]` in blue
    color indicating that the local branch *main* is now tracking the remote
    branch:

    <img src="https://raw.githubusercontent.com/sgra64/dotfiles/refs/heads/markup/img/tracking-branch.png" width="800"/>

    ```sh
     # verify the linkage by pushing and pulling again with "everything is up-to-date" messages
    git push origin main
    --> "Everything up-to-date"

    git pull origin main
    --> "Already up to date"
    ```

At this stage, the local branch *main* is linked to the remote branch
*origin/main* as a *"tracking branch"*.

More *dotfiles* can be added to *main* and pushed to *origin/main* providing
protection for loss or undesired changes of *dotfiles*.
