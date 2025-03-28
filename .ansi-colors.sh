# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# ANSI terminal control sequences for colors:
# - https://en.wikipedia.org/wiki/ANSI_escape_code
# - https://askubuntu.com/questions/466198/how-do-i-change-the-color-for-directories-with-ls-in-the-console
# - https://www.howtogeek.com/307701/how-to-customize-and-colorize-your-bash-prompt
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

declare -gA ANSI_COLORS=(
    ["black"]="1;30"
    ["dimmed-grey"]="2;30"  ["dimmed-red"]="2;31"   ["dimmed-green"]="2;32"
    ["dimmed-yellow"]="2;33" ["dimmed-blue"]="2;34" ["dimmed-purple"]="2;35"
    ["dimmed-cyan"]="2;36"  ["dimmed-white"]="2;37"

    ["grey"]="1;30"         ["red"]="1;31"          ["green"]="1;32"
    ["yellow"]="1;33"       ["blue"]="1;34"         ["purple"]="1;35"
    ["cyan"]="1;36"         ["white"]="1;37"

    ["low-grey"]="0;30"     ["low-red"]="0;31"      ["low-green"]="0;32"
    ["low-yellow"]="0;33"   ["low-blue"]="0;34"     ["low-purple"]="0;35"
    ["low-cyan"]="0;36"     ["low-white"]="0;37"    # ["low-white"]="0;37;1"

    ["bright-grey"]="1;90"  ["bright-red"]="1;91"   ["bright-green"]="1;92"
    ["bright-yellow"]="1;93" ["bright-blue"]="1;94" ["bright-purple"]="1;95"
    ["bright-cyan"]="1;96"  # turquoise
    ["bright-white"]="1;97" # boldish bright white
    ["light-red-bg"]="1;101"

    ["broken-link"]="1;4;37;41" # used for broken links (white on red background)
)

function ansi_code() {
    local code=$1
    local text=$2
    local reset="\[\e[0m\]"     # alternatively: "\[\033[0m\]"
    # 
    case "$code" in
    "reset")    printf "%s%s" "$reset" "$text" ;;
    "0")        printf "0" ;;
    *)          local esc=${ANSI_COLORS[$code]}
                [ "$text" = "--unterminated" ] && text="" && reset=""
                [ "$esc" ] && printf "\[\e[%sm\]%s%s" "$esc" "$text" "$reset" ;;
    esac
}

function colorize_prompt() {
    # arg1 tells to set color (true) or not (false)
    local s=0; local code=""; local e=""
    for k in "$@"; do
        [ "$s" = 0 -a "$k" = false ] && s=10 && continue
        [ "$s" = 0 -a "$k" = true ] && s=20 && continue
        # 
        # monochrome prompt
        [ "$s" = 10 ] && s=11 && continue
        [ "$s" = 11 ] && s=10 && e+="$k" && continue
        # 
        # colored prompt
        [ "$s" = 20 ] && s=21 && code="$k" && continue
        [ "$s" = 21 ] && s=20 && \
            e+=$(ansi_code "$code" "$k") && \
            code="" && continue
    done;
    # 
    # append unterminated color code (no '\[\e[0m\]' after text) to
    # allow colored typing (commands)
    [ "$1" = true ] && [ "$code" ] && e+=$(ansi_code "$code" "--unterminated")
    # 
    printf "%s" "$e"    # output sequence for PS1 (must quote "$e")
}

function colorize_ls_colors() {
    local s=0; local e=""
    for k in "$@"; do
        [ "$s" = 1 ] && e+="${ANSI_COLORS[$k]}" && s=2
        [ "$s" = 0 ] && e+="$k=" && s=1
        [ "$s" = 2 ] && e+=":" && s=0
    done;
    printf "%s" "$e"     # output sequence for LS_COLORS (must quote "$e")
}


# https://stackoverflow.com/questions/6159856/how-do-zsh-ansi-colour-codes-work
# for COLOR in {0..255}; do
#     for STYLE in "38;5"; do 
#         TAG="\033[${STYLE};${COLOR}m"
#         STR="${STYLE};${COLOR}"
#         echo -ne "${TAG}${STR}${NONE}  "
#     done
#     echo
# done

# further control sequences for ANSI terminal:
# - Put the cursor at line L and column C \033[<L>;<C>H
# - Put the cursor at line L and column C \033[<L>;<C>f
# - Move the cursor up N lines            \033[<N>A
# - Move the cursor down N lines          \033[<N>B
# - Move the cursor forward N columns     \033[<N>C
# - Move the cursor backward N columns    \033[<N>D
# - Clear the screen, move to (0,0)       \033[2J
# - Erase to end of line                  \033[K
# - Save cursor position                  \033[s
# - Restore cursor position               \033[u
