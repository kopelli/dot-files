# Alias from https://unix.stackexchange.com/a/351222
function git_move() {
    if [ x`git rev-parse --show-toplevel 2> /dev/null` = x ];
    then
        # not in a git repo, perform standard git_move
        mv "$@"
    else
        git mv "$@"
    fi
}

alias mv=git_move
