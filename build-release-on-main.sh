# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Build a release with no history on main-branch:
# - f7c2c33 (HEAD -> main, origin/main) dotfiles RELEASE-1.2.2, Aug-05-2025
# - c5ec468 (tag: root) root commit (empty)
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

# execute build-function ("$@" keeps separate arguments, "$*" creates a single string)
build_release_on_main "$@"


# function probe() {
#     cd dev
#     echo "in dev:"
#     git diff home-dev/dev --name-status
#     git diff origin/dev --name-status
#     cd ..
# }
# function update_local_dev() {
#     [ "$1" ] && local sub_div="$1" || sub_div="dev"
#     [ -d "$sub_div" ] && local cd_back=$(pwd) && builtin cd "$sub_div"
#     git pull home-dev dev
#     git push origin dev
#     [ "$cd_back" ] && builtin cd "$cd_back"
# }
# function build_release_on_main() {
#     [ "$1" ] && local sub_div="$1" || sub_div="main"
#     [ -d "$sub_div" ] && local cd_back=$(pwd) && builtin cd "$sub_div
#     git reset --hard root
#     git pull --squash local-dev dev
#     git commit -m "${PX[release-commit-msg]}"
#     git push -f origin main
#     [ "$cd_back" ] && builtin cd "$cd_back"
# }
# 
# git clone -b main --single-branch git@github.com:sgra64/dotfiles.git main
# cd main
# git remote add local-dev ../dev
# 
# git clone -b dev --single-branch git@github.com:sgra64/dotfiles.git dev
# cd dev; git remote add home-dev $HOME
# 