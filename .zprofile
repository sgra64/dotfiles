# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# .zprofile is executed by zsh (Mac) when a new terminal is opened.
# \\
# .zprofile invokes .profile from bash and automatically invokes .zshrc
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# 
[ -z "$SHELL" ] && export SHELL="$(ps -p $$ | sed -e '/PID/d' -e 's/.* //g')"
[[ "$SHELL" =~ zsh ]] && export ZSH="$SHELL" || export ZSH="/bin/zsh"

[ -f ".profile" ] &&
    builtin source ".profile"
