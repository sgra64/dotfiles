#!/bin/bash
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Build a release with no history on main-branch:
# - f7c2c33 (HEAD -> main, origin/main) dotfiles RELEASE-1.2.2, Aug-05-2025
# - c5ec468 (tag: root) root commit (empty)
# 
# Steps:
#  1. push update to remote 'dev'-branch
#  2. on local build branch, update message in 'release.txt'
#  3. run build-script:
#     - eval build-release-on-main.sh --push
#     build-script will build new release on 'main'-branch and push to remote
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function build_release_on_main() {
    git switch main
    local branch=$(git rev-parse --abbrev-ref HEAD)
    # 
    if [ "$branch" = "main" ]; then
        [ "$1" = "--push" ] && local push=true
        # 
        # set remote 'origin' if not present
        [ -z "$(git remote -v | grep origin)" ] && \
            git remote add origin git@github.com:sgra64/dotfiles.git
        # 
        [ -f "release.txt" ] && local rel=$(<release.txt) || local rel="dotfiles RELEASE-1.2.2, Aug-09 2025"
        # 
        # reset branch 'main' to initial root commit and pull content of 'dev'
        git reset --hard root
        git pull --squash origin dev

        # remove name/email-entries from '.gitconfig' using 'gitconfig.patch'
        git fetch origin build
        git checkout origin/build gitconfig.patch README.md
        git apply gitconfig.patch
        # remove .patch files
        git add .gitconfig
        git rm -f *.patch

        # see release numbers
        git log origin/dev | grep '    '

        # git commit -m "dotfiles RELEASE-${rel}, $(date '+%b-%d-%Y')"
        git commit -m "${rel}"
        # 
        # if requested, push
        [ "$push" ] && git push -f origin main
        # 
        git switch build
    else
        echo "could not switch to branch 'main'"
    fi
}

# execute build-function ($@ keeps separate arguments, "$*" creates a single string)
build_release_on_main $@
