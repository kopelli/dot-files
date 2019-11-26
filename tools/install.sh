#!/bin/bash

# Need to find where this file is being run from
# Since it may be symlinked, need to trace down the *actual* location.
# See https://stackoverflow.com/a/246128/6504 for more explaination.
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do #resolve $SOURCE until it is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
unset SOURCE

install_sh() {
  echo "Executing shell script installers..."
  if [[ -d "$DIR/sh" ]]; then
    for FILE in $("ls" -1 "$DIR/sh/"*.sh) ; do
      FILE="./$(realpath --relative-to="${PWD}" "$FILE")"
      echo "Executing \"$FILE\"..."
      bash "$FILE"
    done
  fi
}

install_apt() {
  if [[ $(which apt) ]]; then
    # Use this trick to determine if we need to prefix the "sudo" command
    # Tkane from https://stackoverflow.com/a/21622456/6504
    local SUDO=''
    if (( $EUID != 0 )); then
      SUDO='sudo'
    fi

    $SUDO apt-get -qq update
    if [[ -d "$DIR/apt" ]]; then
      local PACKAGES=''
      for FILE in $("ls" -1 "$DIR/apt/"*.apt) ; do
        PACKAGES="$PACKAGES $(basename "$FILE" .apt)"
      done

      if [[ "$PACKAGES" != "" ]]; then
        echo "$SUDO apt-get -q install $PACKAGES..."
        $SUDO apt-get -q install $PACKAGES
      fi
    fi
  else
    echo "Apt isn't installed, skipping..."
  fi
}

install_git() {
  XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}
  if [[ $(which git) ]]; then
    echo "Need to clone some git repos..."
    if [[ -d "$DIR/git" ]]; then
      for FILE in $("ls" -1 "$DIR/git/"*.clone) ; do
        local CLONE_PATH=$XDG_DATA_HOME/cloned-repos/$(basename "$FILE" .clone)
        if [[ ! -d "$CLONE_PATH" ]]; then
          echo "Need to make the git clone directory $CLONE_PATH"
          mkdir -p "$CLONE_PATH"
          git -C "$CLONE_PATH" init -q
          git -C "$CLONE_PATH" config remote.origin.url "$("cat" $FILE)"
          git -C "$CLONE_PATH" config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
          git -C "$CLONE_PATH" config core.autocrlf "false"
        fi
        echo "git fetch origin master:origin/master --tags --force"
        git -C "$CLONE_PATH" fetch origin master:origin/master --tags --force
        git -C "$CLONE_PATH" reset --hard "origin/master"
        bash "$DIR/git/$(basename "$FILE" .clone).install.sh"
      done
    fi
  else
    echo "Git isn't available, skipping..."
  fi
}

install_brew() {
  if [[ $(which brew) ]]; then
    echo "Need to brew install some packages..."
    if [[ -d "$DIR/brew" ]]; then
      for TAP in $("ls" -1 "$DIR/brew/"*.tap) ; do
        echo "brew tap $("cat" $TAP)"
        brew tap $("cat" $TAP)
      done

      local BOTTLES=''
      for FILE in $("ls" -1 "$DIR/brew/"*.brew) ; do
        BOTTLES="$BOTTLES $(basename "$FILE" .brew)"
      done
      if [[ "$BOTTLES" != "" ]]; then
        echo "brew install $BOTTLES..."
        brew install $BOTTLES
      fi

      # Casks are MacOS only...
      if [[ "$osname" == "Darwin" ]]; then
        local CASKS=''
        for FILE in $("ls" -1 "$DIR/brew/"*.cask) ; do
          CASKS="$CASKS $(basename "$FILE" .cask)"
        done
        if [[ "$CASKS" != "" ]]; then
          echo "brew cask install $CASKS..."
          brew cask install $CASKS
        fi
      fi
    fi
  else
    echo "Brew isn't available, skipping..."
  fi
}

osname=$(uname -s)
case $osname in
  "Linux")
    install_sh
    install_apt
    install_brew
    install_git
    ;;
  "Darwin")
    install_sh
    install_brew
    install_git
    ;;
  *)
    echo "...not sure about \"$osname\"..."
esac
