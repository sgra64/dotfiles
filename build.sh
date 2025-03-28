
declare -gA PX
PX[main-build-dir]="main"
PX[main-dev-build-dir]="main-dev"
PX[root-git]="git-main-root.tar"    # repo with empty root commit
PX[main-dev]="main-dev"             # 'main-dev' branch and build directory
PX[origin]="git@github.com:sgra64/dotfiles.git"
# 
PX[version]="1.1.0"
PX[main-commit-line]="dotfiles release-${PX[version]}"


function build() {
    case "$1" in

    # pull 'main-dev' branch from remote repository
    main-dev)
        local build_dir="${PX[main-dev-build-dir]}"
        [ -d "$build_dir" ] && rm -rf "$build_dir"
        # 
        # pull branch 'main-dev' from remote repository
        git clone -b "${PX[main-dev]}" --single-branch "${PX[origin]}" "${PX[main-dev]}"
        builtin cd "$build_dir"
        # 
        echo -e "pulled branch \047$build_dir\047 from remote \047dev/${PX[origin]}\047"
        # 
        # pull updates from local dev repo (in $HOME)
        echo "pull updates from local dev repo ($HOME)"
        git remote add "local-dev" "$HOME"
        git pull local-dev "${PX[main-dev]}"
        # 
        echo -e "\n******\nconsider pushing local dev updates to remote:"
        echo " - git push origin"
        ;;

    # build 'main' branch pushed to remote repository
    main)
        local build_dir="${PX[main-build-dir]}"
        [ -d "$build_dir" ] && rm -rf "$build_dir"
        mkdir "$build_dir"
        builtin cd "$build_dir"
        # 
        tar xf "../${PX[root-git]}"
        # 
        # add remote 'dev' repository to pull 'main-dev' branch
        # [ -z "$(git remote get-url dev 2>/dev/null)" ] && \
        #     git remote add dev "${PX[rdev]}"
        git remote add dev "../${PX[main-dev]}"
        # 
        # pull 'main-dev' branch from remote 'dev' repository
        local version="${PX[version]}"
        local date=$(date +'%y%m%d')
        git pull --squash dev "${PX[main-dev]}"
        # 
        # patch .gitconfig to put name and email in comments
        # create patch file the original file and a file with changes:
        # diff -Naru .gitconfig .gitconfig.to_be > ../gitconfig.patch
        [ -f "../gitconfig.patch" ] && \
            echo "patching: patch .gitconfig < ../gitconfig.patch" && \
            patch .gitconfig < ../gitconfig.patch && \
            git add .gitconfig
        # 
        git status
        # use same commit message to show uniformly in github
        git commit -m "${PX[main-commit-line]}" 2>/dev/null
        # 
        # remove remote branch and remote
        git branch -rd "${PX[main-dev]}"
        git remote remove dev
        prune >/dev/null
        # 
        # package .git as .tar and .zip
        tar cf dotfiles$date-$version.tar .git >/dev/null
        zip -r  dotfiles$date-$version.zip .git >/dev/null
        cp ../README.md .
        # 
        git add -f README.md dotfiles*.{tar,zip}
        git commit -m "${PX[main-commit-line]}"
        echo -e "built branch 'main' from \047dev/${PX[main-dev]}\047"
        # 
        git remote add origin "${PX[origin]}"
        # 
        if [ "$2" = "push" -o "$2" = "--push" ]; then
            git push -f origin main
            echo -e " - pushed to remote \047dev/${PX[origin]}\047)"
        else
            echo -e "\n******\nconsider pushing \047main\047 branch to remote:"
            echo " - git push -f origin main"
        fi
        # builtin cd ..
        ;;

    esac
}
