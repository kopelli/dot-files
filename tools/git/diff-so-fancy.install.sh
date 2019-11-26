
_SUDO=''
if (( $EUID != 0 )); then
  _SUDO='sudo'
fi

XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}
if [[ -d "$XDG_DATA_HOME/cloned-repos/diff-so-fancy/third_party/build_fatpack" ]]; then
  $_SUDO ln -s $XDG_DATA_HOME/cloned-repos/diff-so-fancy/third_party/build_fatpack/diff-so-fancy /usr/local/bin/diff-so-fancy
fi
