#!/bin/bash

_menu_text="Select all that you would like to install\nPress [Enter] to continue installation"
_option_bash=('BASH' ".bashrc" ON)
_option_git=('GIT' "Git configuration" ON)
_option_tmux=('TMUX' "TMUX configuration" ON)
_option_vim=('VIM' "Vim config & plugins" ON)
_option_sh=('sh' "Bash script installers" ON)
_option_apt=('apt' "APT packages" ON)
_option_gitrepo=('gitrepos' "Direct Git repos" ON)
_option_brew=('brew' "Homebrew/Linuxbrew" ON)


read _height _width < <(stty size)
_optionCount=8 # This should be how many `_option...` variables are above
_height=$(( $_height < $_optionCount + 10 ? $_height : $_optionCount + 10 )) # set minimum height

# check out https://askubuntu.com/a/781062 for color info
toInstall=$(NEWT_COLORS='
  root=white,black
  window=,black
	border=white,black
	textbox=green,black
	button=white,black
	checkbox=green,black
	actcheckbox=black,green
' \
whiptail \
  --fullbuttons \
  --notags \
  --ok-button "Install" \
  --checklist \
  "$_menu_text" \
  $_height \
  $_width \
  $_optionCount \
  "${_option_bash[@]}" \
  "${_option_git[@]}" \
  "${_option_tmux[@]}" \
  "${_option_vim[@]}" \
  "${_option_sh[@]}" \
  "${_option_apt[@]}" \
  "${_option_gitrepo[@]}" \
  "${_option_brew[@]}" 3>&1 1>&2 2>&3)

if [[ ${#toInstall} -eq 0 ]]; then
  exit 0
fi

TRUE=1
FALSE=0

osname=$(uname -s)
echo "You are running $osname"

function is_in_git_repo() {
    git rev-parse 2> /dev/null
}

IS_IN_GIT_REPO=$(is_in_git_repo && echo $TRUE)
IS_IN_GIT_REPO=${IS_IN_GIT_REPO:-$FALSE}

if [[ "$IS_IN_GIT_REPO" -eq "$TRUE" ]]; then
    echo "We're in a git repo, so assume this is the install directory"
    # TODO: Loop through remotes and make sure one of them matches
    # TODO: Find the root of the git repo
    install_dir="$(pwd)"
else
    echo "Where do you want to download the repo to?"
    echo "The 'dot-files' directory will be created automatically"
    read -p "($(pwd)): " install_dir </dev/tty
    install_dir=${install_dir:-$(pwd)}/dot-files
    git clone --depth 1 --no-tags --origin "upstream" https://github.com/kopelli/dot-files "${install_dir}"
    git -C "${install_dir}" remote set-url --push "upstream" "DISALLOWED"
fi

# IF in git, then loop through remotes and see if it's our expected dot-files
# otherwise prompt for download


echo "Install directory is \"${install_dir}\""
for option in $toInstall
do
  case $option in
    "\"${_option_bash[0]}\"")
      echo "Installing bash..."
      ln -fs ${install_dir}/.bash/bashrc ~/.bashrc
      ;;
    "\"${_option_git[0]}\"")
      echo "Installing git..."
      ln -fs ${install_dir}/.git-config/config ~/.gitconfig
      ln -fs ${install_dir}/.git-config/ ~/
      ;;
    "\"${_option_tmux[0]}\"")
      echo "Installing tmux..."
      ln -fs ${install_dir}/_tmux.conf ~/.tmux.conf
      ;;
    "\"${_option_vim[0]}\"")
      echo "Installing vim..."
      ln -fs ${install_dir}/.vim/_vimrc ~/.vimrc
      ln -fs ${install_dir}/.vim/ ~/

      echo "Installing vim plugins..."
      </dev/tty vim +PlugInstall +qall
      ;;
    "\"${_option_sh[0]}\"")
      if [[ -d "${install_dir}/tools/sh" ]]; then
        echo "Executing shell script installers..."
        for FILE in $("ls" -1 "$install_dir/tools/sh/"*.sh) ; do
          FILE="./$(realpath --relative-to="${PWD}" "$FILE")"
          echo "Executing \"$FILE\"..."
          bash "$FILE"
        done
      else
        echo "Cannot execute shell script installers. Expected directory does not exist!"
      fi
      ;;
    "\"${_option_apt[0]}\"")
      if [[ $(which apt) ]]; then
        # Use this trick to determine if we need to prefix the "sudo" command"
        # Taken from https://stackoverflow.com/a/21622456/6504
        local SUDO=''
        if (( $EUID != 0 )); then
          SUDO='sudo'
        fi

        $SUDO apt-get -qq update
        if [[ -d "${install_dir}/tools/apt" ]]; then
          local PACKAGES=''
          for FILE in $("ls" -1 "${install_dir}/tools/apt/"*.apt) ; do
            PACKAGES="$PACKAGES $(basename "$FILE" .apt)"
          done

          if [[ "$PACKAGES" != "" ]]; then
            echo "$SUDO apt-get -q install $PACKAGES..."
            $SUDO apt-get -q install $PACKAGES
          fi
        fi
      else
        echo "Apt is not installed, skipping..."
      fi
      ;;
    "\"${_option_gitrepo[0]}\"")
      XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}
      if [[ $(which git) ]]; then
        echo "Starting to clone git repos..."
        if [[ -d "${install_dir}/tools/git" ]]; then
          for FILE in $("ls" -1 "${install_dir}/tools/git/"*.clone) ; do
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
            bash "${install_dir}/tools/git/$(basename "$FILE" .clone).install.sh"
          done
        fi
      else
        echo "Git is not available, skipping..."
      fi
      ;;
    "\"${_option_brew[0]}\"")
      if [[ $(which brew) ]]; then
        echo "Starting to brew install some packages..."
        if [[ -d "${install_dir}/tools/brew" ]]; then
          for TAP in $("ls" -1 "${install_dir}/tools/brew/"*.tap) ; do
            local TAP_REPO=$("cat" $TAP)
            TAP_REPO="${TAP_REPO/$'\r'/}"
            if [[ "$(brew tap | grep ${TAP_REPO})" == "" ]]; then
              echo "brew tap $TAP_REPO"
              brew tap $TAP_REPO
            fi
          done

          local BOTTLES=''
          for FILE in $("ls" -1 "${install_dir}/tools/brew/"*.brew) ; do
            BOTTLES="$BOTTLES $(basename "$FILE" .brew)"
          done
          if [[ "$BOTTLES" != "" ]]; then
            echo "brew install $BOTTLES..."
            brew install $BOTTLES
          fi

          # Casks are MacOS only...
          if [[ "$osname" == "Darwin" ]]; then
            local CASKS=''
            for FILE in $("ls" -1 "${install_dir}/tools/brew/"*.cask) ; do
              CASKS="$CASKS $(basename $"FILE" .cask)"
            done
            if [[ "$CASKS" != "" ]]; then
              echo "brew cask install $CASKS..."
              brew cask install $CASKS
            fi
          fi
        fi
      else
        echo "Brew is not installed, skipping..."
      fi
      ;;
    *)
      echo "...I have no idea what to do for \"$option\"..."
      ;;
  esac
done

if [[ $toInstall =~ "\"${_option_bash[0]}\"" ]]; then
  source ~/.bashrc
fi
