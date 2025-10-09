#!/bin/bash
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Clear, checkout and pull (update) dotfiles in $HOME directory:
# - .bash_logout
# - .bashrc
# - .bashrc.path
# - .gitconfig
# - .gitignore
# - .minttyrc
# - .profile
# - .tmux/
# - .vimrc
# - .vscode_global/
# - .zprofile
# - .zshrc
# 
function clear_dotfiles() {
    local remove=(.bash_logout .bashrc .bashrc.path .gitconfig .gitignore \
        .minttyrc .profile .tmux .vimrc .vscode_global .zprofile .zshrc \
        README.md checkout.sh)
    # 
    rm -rf ${remove[@]} $@
}

function checkout_dotfiles_as_dev() {
    git init --initial-branch=dev
    git remote add origin git@github.com:sgra64/dotfiles.git
    git pull origin dev
    # 
    # make branch 'dev' track remote branch 'origin/dev'
    git branch --set-upstream-to=origin/dev dev
}

function checkout_dotfiles() {
    clear_dotfiles .git
    git init --initial-branch=main
    git remote add origin git@github.com:sgra64/dotfiles.git
    # 
    # specify origin main to avoid fetching all remote branches
    git pull origin main --squash --strategy-option=theirs
    # 
    # commit eventually open merge (--squash)
    git status | grep "nothing to commit" > /dev/null && [ $? = 0 ] ||
        git commit -m "merge origin/main"
    # 
    # apply patch to restore name and email in .gitconfig
    local patch="gitconfig-add-my-name-and-email.patch"
    git fetch origin build:refs/remotes/origin/build
    git checkout origin/build gitconfig-add-my-name-and-email.patch
    git apply "$patch" &&
        git add .gitconfig && git rm -f "$patch" &&
        git commit -m "name and email restored in .gitconfig"
    # 
    # remove files, prevent them from coming back in subsequent pulls
    local remove=(README.md checkout.sh)
    for r in ${remove[@]}; do
        [ -f "$r" ] && git rm "$r" && removed+=("$r")
    done
    [ ${#removed[@]} -gt 0 ] && git commit -m "rm ${removed[@]}"
    # 
    # set local branch 'main' to track remote branch 'origin/main'
    git branch -u origin/main main
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Checkout repository into 'dotfiles' folder
# 
# <dotfiles>        # main branch only
#  |
#  +-<branches>     # sub-dir with individual branches
#      +-<dev>
#      +-<build>
#      +-<markup>
#      +-<prior>
# 
function checkout_dotfiles_repo() {
    [ -e "dotfiles" ] && echo "'dotfiles' already exists, remove" && return 1
    # 
    git clone --single-branch -b main git@github.com:sgra64/dotfiles.git
    cd dotfiles
    mkdir branches && cd branches
    # 
    local branches=(dev build markup)
    for branch in ${branches[@]}; do
        echo "--> checking out branch: $branch"
        git clone --single-branch -b $branch git@github.com:sgra64/dotfiles.git $branch
    done
    cd ../..
}
