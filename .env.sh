# 
# - build:  Ctrl-Shift-B
# - run:    Ctrl-Alt-N
# - Clean Java Language Server Workspace: Ctrl-Shift-P
# 
# - C:\Users\<USER>\AppData\Roaming\Code\User\workspaceStorage
# - ~/Library/Application Support/Code/User/workspaceStorage
# 
# [ "$(uname | grep 'CYGWIN\|MINGW')" ] && export MSYS="winsymlinks:nativestrict"
# [ "$(uname | grep 'CYGWIN\|MINGW')" ] && local sep=';' || local sep=':'
# 
declare -gA P=(
    [src]="src"
    [tests]="tests"
    [res]="resources"
    [lib]="libs"
    [lib-repo]="git clone -b libs --single-branch git@github.com:sgra64/se1-play.git"
    [target]="bin"
    [classes]="bin/classes"
    [test-classes]="bin/test-classes"
    [test-runner]="junit-platform-console-standalone-1.9.2.jar"
    [run]="application.Application A BC DEF"
    [log-dir]="logs"
    [doc-dir]="docs"
    [cov-dir]="coverage"
    [env-script]=".env.sh"
    [jar]="bin/application-1.0.0-SNAPSHOT.jar"
    # 
    [is-zsh]=$(type setopt 2>/dev/null)
    [is-win]=$([[ "$(uname)" =~ (CYGWIN|MINGW) ]] && echo true)
    [created-env]=""
    [created-files]=""
)

# trap: disable zsh from outputting ANSI escape characters in sub-processes confusing
# results such as in commands: wc $(find tmp -name '*.py') or colors="${colors:3}"
# 
# disable 'no matches found:' message in zsh 
[ "${P[is-zsh]}" ] && \
    trap "" DEBUG && \
    setopt no_nomatch


function setup() {
    # [[ "$(uname)" =~ (CYGWIN|MINGW) ]] && is_win="true"
    # standalone="false"
    [ ! -d src -o ! -d .git ] && echo "must run in project folder" && return 1
    # 
    [ -z "$PROJECT_PATH" ] && \
        export PROJECT_PATH="$(pwd)" && \
        created env "PROJECT_PATH: \"${PROJECT_PATH}\""
    # 
    local lib="${P[lib]}"
    if [ ! -d "$lib" ]; then
        local search_dirs=( .. ../.. branches ../branches )
        for p in ${search_dirs[@]}; do
            local p="$p/$lib"
            if [ -d "$p" ]; then
                # MinGW (GitBash) requires MSYS be set for symlinks
                # https://www.joshkel.com/2018/01/18/symlinks-in-windows/
                [ "${P[is-win]}" ] && export MSYS="winsymlinks:nativestrict"
                ln -s "$p" "$lib"
                created file ln -s "$p" "$lib"
                break
            fi
        done
        # if not found to link, check libs out from git
        [ ! -d "$lib" ] && \
            eval ${P[lib-repo]} "$lib" && \
            created file ${P[lib-repo]} "$lib"
    fi

    if [ "$1" = "--setup-classpath" ]; then
        setup_classpath
        unset -f setup_classpath classpath_file template trlink
    fi

    [ -z "$JDK_JAVAC_OPTIONS" ] &&
        export JDK_JAVAC_OPTIONS="-Xlint:-options -Xlint:-module -d "${P[classes]}" --module-path \"$MODULEPATH\"" && \
        created env JDK_JAVAC_OPTIONS

    [ -z "$JDK_JAVADOC_OPTIONS" ] && local jdoc="--source-path "${P[src]}" -d "${P[doc-dir]} && \
        jdoc+=" --module-path \"$MODULEPATH\"" && \
        jdoc+=" -version -author -Xdoclint:-missing" && \
        jdoc+=" -noqualifier \"java.*:application.*:datamodel.*:system.*\"" && \
        export JDK_JAVADOC_OPTIONS="$jdoc" && \
        created env JDK_JAVADOC_OPTIONS

    [ -z "$JUNIT_OPTIONS" ] &&
        export JUNIT_OPTIONS="--details-theme=unicode" && \
        created env JUNIT_OPTIONS

    [ -z "$JACOCO_AGENT" ] &&
        agent_jar=$(tr ';' '\n' <<< $JUNIT_CLASSPATH | grep 'jacocoagent.jar') && \
        export JACOCO_AGENT="-javaagent:"$agent_jar"=output=file,destfile="${P[cov-dir]}"/jacoco.exec" && \
        created env JACOCO_AGENT
    # 
    [ "${P[is-zsh]}" ] && \
        trap "echo -ne '\e[m'" DEBUG    # reset formatting after command + ENTER
    # 
    created show
    # 
    return 0
}

function wipe() {
    local env=(PROJECT_PATH CLASSPATH JUNIT_CLASSPATH MODULEPATH \
                JDK_JAVAC_OPTIONS JDK_JAVADOC_OPTIONS JUNIT_OPTIONS JACOCO_AGENT \
    )
    local files=(.classpath .vscode/.classpath .project)
    # 
    local env2=()
    for e in ${env[@]}; do  # collect var that have been set
        [ "$(eval echo '$'$e)" ] && env2+=($e)
    done
    # 
    [[ "${#env2[@]}" -gt 0 ]] && \
        unset "${env2[@]}" && echo "unset variables: ${env2[@]}"
    # 
    [[ "$1" =~ (-a|--all|-la) ]] && \
        unset -f wipe && \
        rm -rf ${files[@]} && echo "removed files: ${files[@]}" && \
        [[ "$1" =~ (-la) ]] && \
            rm -rf "${P[lib]}" && echo "removed: ${P[lib]}"
}

function command() {
    case "$1" in

    clean) echo rm -rf ${P[target]} ${P[log-dir]} ${P[doc-dir]} ${P[cov-dir]}
        ;;

    compile)
        echo javac $\(find ${P[src]} -name \'*.java\'\) -d ${P[classes]}';'
        command copy-resources
        ;;

    compile-tests) echo javac -cp \$JUNIT_CLASSPATH $\(find ${P[tests]} -name \'*.java\'\) -d ${P[test-classes]}';'
        command copy-resources
        ;;

    copy-resources) echo copy ${P[res]} ${P[target]}/${P[res]}
        ;;

    run) echo java ${P[run]}
        ;;

    run-tests) echo java -cp \$JUNIT_CLASSPATH \\
        echo " " org.junit.platform.console.ConsoleLauncher \$JUNIT_OPTIONS \\
        echo " " --scan-class-path
        ;;

    package|jar)
        echo tar cv ${P[lib]}/'{jackson,logging}*/*' "| tar -C ${P[target]} -xvf - "';'
        echo jar -c -v -f ${P[jar]} '\'
        echo "     " -m ${P[res]}/META-INF/MANIFEST.MF '\'
        echo "     " -C ${P[classes]} . ';'
        echo jar uvf ${P[jar]} -C ${P[target]} ${P[res]}
        ;;

    build)
        echo mk clean compile compile-tests run-tests package javadoc
        ;;

    tests)
        echo mk compile compile-tests run-tests
        ;;

    coverage)
        echo java $\(eval echo \$JACOCO_AGENT\) $\(eval echo \$JUNIT_CLASSPATH\) \\
        echo " " org.junit.platform.console.ConsoleLauncher $\(eval echo \$JUNIT_OPTIONS\) \\
        echo " " --scan-class-path';'
        echo echo coverage events recorded in: ${P[cov-dir]}/jacoco.exec
        ;;

    doc|docs|javadoc)
        echo javadoc -d docs $\(eval echo \$JDK_JAVADOC_OPTIONS\) \\
        echo " " $\(builtin cd ${P[src]}\; find . -type d \| sed -e \'s!/!.!g\' -e \'s/^[.]*//\'\)
        ;;

    esac; return 0
}

function mk() {
    for cmd in "$@"; do
        if [ "$(command $cmd)" ]; then
            # 
            # output command in terminal
            command "$cmd"
            # echo '------'
            # 
            # disable ANSI-codes for 'zsh' during command execution
            [ "${P[is-zsh]}" ] && trap "" DEBUG
            # 
            eval $(command "$cmd" | sed -e 's/\\$//' | tr -d '\n')
            # 
            # re-enable ANSI-codes for 'zsh' after command execution
            [ "${P[is-zsh]}" ] && trap "echo -ne '\e[m'" DEBUG
        else
            [[ "$cmd" =~ (show|-show|--show) ]] && shift && show "$*" && break
        fi
    done; return 0
}

function show() {
    [ "$1" ] && local args=($*) || local args=( \
        clean compile compile-tests run run-tests build package coverage javadoc \
    )
    local last=${args[-1]}
    for cmd in ${args[@]}; do
        if [ "$(command $cmd)" ]; then
            echo $cmd:
            command $cmd | sed -e 's/.*/  &/'
            [ "$cmd" != "$last" ] && echo    # line feed, except for last command
        fi
    done; return 0
}

# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
# Copy content of (resource) directory passed as first argument to directory
# passed as second argumet, except 'META-INF' directory.
# Usage:
#   copy [from_dir] [to_dir]
# @param from_dir source directory from which content is recursively copied
# @param to_dir destination directory
function copy() {
    local from_dir="$1"
    local to_dir="$2"
    if [ -z "$from_dir" ] || [ -z "$to_dir" ]; then
        echo "use: copy <from-dir> <to-dir>"
    else
        [[ ! -d "$to_dir" ]] && mkdir -p $to_dir
        # find $from_dir ! -path '*META-INF*' -type f | xargs cp --parent -t $to_dir
        tar -cpf - -C $from_dir --exclude='META-INF' . | tar xpf - -C $to_dir
    fi
}

function created() {
    case "$1" in
    env)    shift; local args="$@"; P[created-env]+="$args@@" ;;
    file)   shift; local args="$@"; P[created-files]+="$args@@" ;;
    show)
        [ "${P[created-env]}" ] && \
            echo " - created environment variables:" && \
            sed -e 's/@@/\n/g' <<< ${P[created-env]} | sed -e 's/^.*$/    - &/' -e '$d'
        # 
        if [ "${P[created-files]}" ]; then
            echo " - created folders or files:"
            sed -e 's/@@/\n/g' <<< ${P[created-files]} | sed -e 's/^.*$/    - &/' -e '$d'
        fi ;;
    esac
    return 0
}

# 
# ------ setup-classpath: -----------------------------------------------------
# 
if [ -z "$CLASSPATH" -o -z "$JUNIT_CLASSPATH" -o -z "$MODULEPATH" -o ! \
        -f .classpath -o ! -f .vscode/.classpath -o ! -f .project ]; then

    function setup_classpath() {
        # CLASSPATH seperator is ';' on Windows, any other system it is ':'
        [ "${P[is-win]}" ] && local sep=';' || local sep=':'
        # 
        # absolute path to libs and path with symbolic links resolved
        local libs_path_abs=$(builtin cd "${P[lib]}"; pwd)
        local libs_path_traced=$(trlink "${P[lib]}" "$libs_path_abs")
        # echo "trlink: --> "$(trlink "${P[lib]}" "$libs_path_abs")
        # 
        # jars with abs path, e.g. /cygdrive/c/home/svgr/libs/lombok/lombok-1.18.36.jar
        local jars_abs=($(find "$libs_path_abs" -name '*.jar'))
        local jars=($(find "$libs_path_traced" -name '*.jar'))
        # 
        local cp=""; local jcp=""
        if [ -z "$CLASSPATH" -o -z "$JUNIT_CLASSPATH" ]; then
            local sep2=""; local sep3=""
            for cpe in  "${P[classes]}" \
                        "${P[test-classes]}" \
                        "${P[target]}/${P[res]}" \
                        ${jars[@]};
            do
                # collect entries for CLASSPATH, exclude 'jacoco' jars with test-runner
                [[ ! "$cpe" =~ (jacoco|test-classes|junit-platform|opentest|apiguardian) ]] && \
                    cp+="$sep2$cpe" && sep2="$sep"
                # 
                # collect entries for JUNIT_CLASSPATH, exclude 'junit' jars
                [[ ! "$cpe" =~ (/junit/) ]] &&
                    jcp+="$sep3$cpe" && sep3="$sep"
                # 
            done
            # jcp+="$sep3$libs_path/${P[test-runner]}" # append junit test-runner
        fi
        [ -z "$CLASSPATH" ] && export CLASSPATH="$cp" && created env CLASSPATH  # ${CLASSPATH:0:52}...
        [ -z "$JUNIT_CLASSPATH" ] && export JUNIT_CLASSPATH="$jcp" && created env JUNIT_CLASSPATH

        if [ -z "$MODULEPATH" ]; then
            local mp=""; local sep2=""
            # cut off trailing jar-name leaving dirname for modulepath
            for mod in $(tr ' ' '\n' <<< ${jars[@]} | sed -e 's|/[^/]*$||' | uniq); do
                mp+="$sep2$mod"; sep2="$sep"
            done
            export MODULEPATH="$mp"
            created env MODULEPATH    # ${MODULEPATH:0:52}"
        fi

        # on Windows, use abs path with C:/ for .classpath file
        if [ ! -f .classpath ]; then
            classpath_file $(for jar in ${jars_abs[@]}; do \
                [ "${P[is-win]}" ] && \
                    sed -e '/jacoco\|junit/d' -e 's!^/cygdrive!!' <<< "$jar" | sed -E 's!^/([[:alpha:]])/!\U\1:/!' || \
                    sed -e '/jacoco\|junit/d' <<< "$jar"; \
                done) > .classpath
            created file ".classpath"
        fi

        [ ! -f .vscode/.classpath ] && \
            echo "$CLASSPATH" > .vscode/.classpath && \
            created file ".vscode/.classpath"

        [ ! -f .project ] && \
            template .project > .project && \
            created file ".project"
        # 
        return 0
    }

    function classpath_file() {
        # substitute template variables
        template .classpath | sed \
            -e 's!@target!'${P[target]}'!g' \
            -e 's!@classes!'${P[classes]}'!g' \
            -e 's!@test-classes!'${P[test-classes]}'!g' \
            -e 's!@resources!'${P[target]}/${P[res]}'!g'
        # 
        for jar in "$@"; do
            # put absolute paths in .classpath to be effective in VS Code launch.json
            template .classpath-entry | sed -e 's!@jar!'$jar'!g'
        done
        # 
        template .classpath-end
    }

    function template() {
        sed -n '/^# -- '"$1"'$/,/^# --/p' "${P[env-script]}" | \
            sed -e '1d' -e '$d' -e 's/^# //'
    }

    function trlink() {
        # 'realpath' command exists (may not on Mac), alt: $(readlink -e "$1")
        [ -f /usr/bin/realpath ] && \
            local tr=$(realpath "$1") && \
            [ "$tr" ] && realpath -s --relative-to="$(pwd)" "$tr" \
        || echo -n "$2"
    }
    # 
    # invoke setup with functions for setting up CLASSPATH, JUNIT_CLASSPATH, MODULEPATH
    # and files: .classpath, .vscode/.classpath, .project
    setup --setup-classpath
else
    # skip setting up CLASSPATH, etc. and files: .classpath, .vscode/.classpath, .project
    setup
fi

unset -f setup created


# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
# Files extractable by extract() separated by markers: '^# -- filename$' and
# '^# --$'.
# 
# -- .classpath
# <?xml version="1.0" encoding="UTF-8"?>
# <classpath>
#     <classpathentry kind="output" path="@target"/>
#     <classpathentry kind="src" path="src" output="@classes"/>
#     <classpathentry kind="src" path="resources" output="@resources" including="**/*.properties|**/*.yaml|**/*.yml"/>
#     <classpathentry kind="src" path="tests" output="@test-classes">
#         <attributes>
#             <attribute name="test" value="true"/>
#         </attributes>
#     </classpathentry>
#     <classpathentry kind="con" path="org.eclipse.jdt.launching.JRE_CONTAINER">
#         <attributes>
#             <attribute name="module" value="true"/>
#         </attributes>
#     </classpathentry>
#     <classpathentry kind="con" path="org.eclipse.jdt.junit.JUNIT_CONTAINER/5">
#         <attributes>
#             <attribute name="module" value="true"/>
#         </attributes>
#     </classpathentry>
# --
# -- .classpath-entry
# <classpathentry kind="lib" path="@jar">
#     <attributes>
#         <attribute name="module" value="true"/>
#     </attributes>
# </classpathentry>
# --
# -- .classpath-end
# </classpath>
# --
# -- .project
# <?xml version="1.0" encoding="UTF-8"?>
# <projectDescription>
#     <name>$name</name>
#     <comment></comment>
#     <projects>
#     </projects>
#     <buildSpec>
#         <buildCommand>
#             <name>org.eclipse.jdt.core.javabuilder</name>
#             <arguments></arguments>
#         </buildCommand>
#     </buildSpec>
#     <natures>
#         <nature>org.eclipse.jdt.core.javanature</nature>
#     </natures>
# </projectDescription>
# --