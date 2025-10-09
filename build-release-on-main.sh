#!/bin/bash
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Build and push a release on the main-branch from the $build_branch sub-
# directory:
# - f7c2c33 (HEAD -> main, origin/main) dotfiles RELEASE-1.2.2, Aug-05-2025
# - c5ec468 (tag: root) root commit (empty)
# 
# Steps:
#  1. push update to remote 'dev'-branch
#  2. on the local build branch, update message in 'release.txt'
#  3. run this build-script:
#     - eval build-release-on-main.sh --push
# The result is in the $build_branch sub-directory.
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function build_release_on_main() {
    local build_branch="built-branch-main"
    [ "$1" = "--push" ] && local push=true

    [ -d "$build_branch" ] && rm -rf "$build_branch"
    git clone --single-branch -b main git@github.com:sgra64/dotfiles.git "$build_branch" &&
        cd "$build_branch" && local in_main=true

    if [ "$in_main" ]; then
        # git reset --hard HEAD~1       # accumulate release history
        git pull --squash origin dev
        # 
        # git fetch origin build:refs/remotes/origin/build
        # git checkout origin/build gitconfig.patch README.md
        cp ../README.md ../checkout.sh .
        git add -f README.md checkout.sh
        # 
        git apply ../gitconfig-remove.patch && git add .gitconfig

        [ -f "../release.txt" ] && local rel=$(<../release.txt) || local rel="dotfiles RELEASE-R1.2.6, Oct-09 2025"
        # git commit -m "dotfiles RELEASE-${rel}, $(date '+%b-%d-%Y')"
        git commit -m "${rel}"
        # 
        # if requested, push
        [ "$push" ] && git push -f origin main && local pushed=" (pushed)"
        # 
        cd ..
        echo -e "-\n--> \"$rel\" built in: \"$build_branch\"$pushed"
    fi
}

# execute build-function ($@ keeps separate arguments, "$*" creates a single string)
build_release_on_main $@
