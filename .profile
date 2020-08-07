#shellcheck disable=SC2039,SC1090
test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"

# Setting PATH for Python 3.6
test -e "/Library/Frameworks/Python.framework/Versions/3.6/bin" && PATH="/Library/Frameworks/Python.framework/Versions/3.6/bin:${PATH}"
export PATH
