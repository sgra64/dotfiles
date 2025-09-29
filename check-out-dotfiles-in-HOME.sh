#!/bin/bash
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Checkout dotfiles in HOME-directory
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

cd $HOME

git init
git remote add origin git@github.com:sgra64/dotfiles.git

# pull 'main'-branch with latest dotfiles release (alt. pull 'dev'-branch)
git pull origin main

# remove 'README.md' from HOME-directory
git rm README.md
git commit -m "remove README.md"

# patch '.gitconfig' to update [user] name and email
# git config --global user.name "Sven Graupner"
# git config --global user.email "sgraupner@bht-berlin.de"
# 
# extract 'gitconfig.patch' from this file
sed -e '1,/^# -- gitconfig.patch$/d' \
    -e '/^# --$/d' \
    -e 's/^# //' \
    < ../check-out-dotfiles-in-HOME.sh > gitconfig.patch

# create patch-file: git diff -- .gitconfig > gitconfig.patch
# apply patch: git apply gitconfig.patch
# 
git apply gitconfig.patch
rm -f gitconfig.patch

# update .gitconfig with user.name, user.email
git add .gitconfig
git commit -m "update .gitconfig with user.name, user.email"

# -- gitconfig.patch
# diff --git a/.gitconfig b/.gitconfig
# index e1956b7..a95dc09 100644
# --- a/.gitconfig
# +++ b/.gitconfig
# @@ -8,10 +8,10 @@
#  # global git config commands:
#  # - git config --global user.name "your name"
#  # - git config --global user.email "your@email.com"
# -# 
# -# [user]
# -#     name = your-name
# -#     email = your@email.com
# +
# +[user]
# +    name = Sven Graupner
# +    email = sgraupner@bht-berlin.de
# 
#  [core]
#      ignorecase = true       # ignore upper/lower case in file names
# 
# --
