
declare -gA PX
PX[origin]="git@github.com:sgra64/dotfiles.git"
# 
PX[version]="1.2.1"
PX[release-commit-msg]="dotfiles RELEASE-${PX[version]}"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# branches:
# - dev: records the development history
# - main: records only the last (current) released commit in remote with all
#         files showing the message of the release commit
# 
# Build process:
# - Starting point is the 'dev'-branch in the local $HOME/.git repository.
# - Commits are then pulled from $HOME/.git(dev) to the local 'dev' branch repo
#   and pushed to the remote 'origin/dev' branch.
# - Next, the release is built in the local 'main' branch repo by resetting the
#   repo back to the 'root' commit and squashing the local 'dev' branch commits
#   into one released commit with msg "PX[release-commit-msg]"."
# - Push -f the local 'main' branch repo to the remote (origin).
# 
function build() {

    [ -z "$(git remote -v | grep origin)" ] && \
        git remote add "origin" "${PX[origin]}"

    # update local branch repo 'dev' from 'dev' branch in $HOME repo
    update_local_dev dev "$HOME"

    # build release in local branch repo 'main' from '../dev' repo
    build_release_on_main main "../dev"
}

function probe() {
    cd dev
    echo "in dev:"
    git diff home-dev/dev --name-status
    git diff origin/dev --name-status
    cd ..
    # 
    cd main
    echo "in main:"
    git diff origin/main --name-status
    cd ..
}

function update_local_dev() {
    [ "$1" ] && local sub_div="$1" || sub_div="dev"
    [ -d "$sub_div" ] && local cd_back=$(pwd) && builtin cd "$sub_div"

    git pull home-dev dev
    git push origin dev

    [ "$cd_back" ] && builtin cd "$cd_back"
}

function build_release_on_main() {
    [ "$1" ] && local sub_div="$1" || sub_div="main"
    [ -d "$sub_div" ] && local cd_back=$(pwd) && builtin cd "$sub_div"

    git reset --hard root
    git pull --squash local-dev dev
    git commit -m "${PX[release-commit-msg]}"
    git push -f origin main

    [ "$cd_back" ] && builtin cd "$cd_back"
}

# set-up remotes in: '.', 'main', 'dev'
# 
# git clone -b main --single-branch git@github.com:sgra64/dotfiles.git main
# cd main
# git remote add local-dev ../dev
# 
# git clone -b dev --single-branch git@github.com:sgra64/dotfiles.git dev
# cd dev
# git remote add home-dev $HOME
# 
