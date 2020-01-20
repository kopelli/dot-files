#!/bin/bash

#==============================================================================
# Menu configuration
#==============================================================================
_menu_text="Select all that you would like to install\nPress [Enter] to continue installation"
_option_bash=('BASH' ".bashrc" ON)
_option_git=('GIT' "Git configuration" ON)
_option_tmux=('TMUX' "TMUX configuration" ON)
_option_vim=('VIM' "Vim config & plugins" ON)
_option_sh=('sh' "Bash script installers" ON)
_option_apt=('apt' "APT packages" ON)
_option_gitrepo=('gitrepos' "Direct Git repos" ON)
_option_brew=('brew' "Homebrew/Linuxbrew" ON)
_optionCount=8 # This should be how many `_option...` variables are above

#==============================================================================
# Functions
#==============================================================================
function install_apt_installers() {
  local APT_DIR="${install_dir}/tools/apt"
  if [[ $(which apt) ]]; then
    # Use this trick to determine if we need to prefix the "sudo" command"
    # Taken from https://stackoverflow.com/a/21622456/6504
    local SUDO=''
    if (( $EUID != 0 )); then
      SUDO='sudo'
    fi

    $SUDO apt-get -qq update
    if [[ -d "${APT_DIR}" ]]; then
      local PACKAGES=''
      for FILE in $("ls" -1 "${APT_DIR}/"*.apt) ; do
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
}

function install_bash() {
  echo "Installing bashrc..."
  ln -fs ${install_dir}/.bash/bashrc ~/.bashrc
}

function install_bash_installers() {
  local SH_DIR="${install_dir}/tools/sh"
  if [[ -d "${SH_DIR}" ]]; then
    echo "Executing shell script installers..."
    for FILE in $("ls" -1 "${SH_DIR}/"*.sh) ; do
      FILE="./$(realpath --relative-to="${PWD}" "$FILE")"
      echo "Executing \"$FILE\"..."
      bash "$FILE"
    done
  else
    echo "Cannot execute shell script installers. Expected directory does not exist!"
  fi
}

function install_git_config() {
  echo "Installing git configuration..."
  ln -fs ${install_dir}/.git-config/config ~/.gitconfig
  ln -fs ${install_dir}/.git-config/ ~/
}

function install_git_repositories() {
  XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}
  local GIT_REPO_DIR="${install_dir}/tools/git"
  if [[ $(which git) ]]; then
    echo "Starting to clone git repos..."
    if [[ -d "${GIT_REPO_DIR}" ]]; then
      for FILE in $("ls" -1 "${GIT_REPO_DIR}/"*.clone) ; do
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
        bash "${GIT_REPO_DIR}/$(basename "$FILE" .clone).install.sh"
      done
    fi
  else
    echo "Git is not available, skipping..."
  fi
}

function install_homebrew_installers() {
  local BREW_DIR="${install_dir}/tools/brew"
  if [[ $(which brew) ]]; then
    echo "Starting to brew install some packages..."
    if [[ -d "${BREW_DIR}" ]]; then
      for TAP in $("ls" -1 "${BREW_DIR}/"*.tap) ; do
        local TAP_REPO=$("cat" $TAP)
        TAP_REPO="${TAP_REPO/$'\r'/}"
        if [[ "$(brew tap | grep ${TAP_REPO})" == "" ]]; then
          echo "brew tap $TAP_REPO"
          brew tap $TAP_REPO
        fi
      done

      local BOTTLES=''
      for FILE in $("ls" -1 "${BREW_DIR}/"*.brew) ; do
        BOTTLES="$BOTTLES $(basename "$FILE" .brew)"
      done
      if [[ "$BOTTLES" != "" ]]; then
        echo "brew install $BOTTLES..."
        brew install $BOTTLES
      fi

      # Casks are MacOS only...
      if [[ "$osname" == "Darwin" ]]; then
        local CASKS=''
        for FILE in $("ls" -1 "${BREW_DIR}/"*.cask) ; do
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
}

function install_tmux_config() {
  echo "Installing tmux configuration..."
  ln -fs ${install_dir}/_tmux.conf ~/.tmux.conf
}

function install_vim_config() {
  echo "Installing vim configuration..."
  ln -fs ${install_dir}/.vim/_vimrc ~/.vimrc
  ln -fs ${install_dir}/.vim/ ~/

  echo "Installing vim plugins..."
  </dev/tty vim +PlugInstall +qall
}

function is_in_git_repo() {
    git rev-parse 2> /dev/null
}

# Establish the height of the menu box
read _height _width < <(stty size)
_height=$(( $_height < $_optionCount + 10 ? $_height : $_optionCount + 10 )) # set minimum height

# While comparing to just integer exit codes _can_ be done,
# let's opt for readability...
TRUE=1
FALSE=0

osname=$(uname -s)

# Some tools just don't make sense on a given OS, so disable them by default
case $osname in
  "Linux")
    ;;
  "Darwin")
    _option_apt[2]=OFF
    ;;
  *)
    echo "...not sure what to do on \"$osname\"..."
esac

#==============================================================================
# Prompt for install choices
#==============================================================================
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

# Should the user clear all checkboxes, there's nothing else for us to do.
# So bail early.
if [[ ${#toInstall} -eq 0 ]]; then
  exit 0
fi


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

#==============================================================================
# Perform installs
#==============================================================================

echo "You are running $osname"
echo "Install directory is \"${install_dir}\""
for option in $toInstall
do
  case $option in
    "\"${_option_bash[0]}\"")
      install_bash
      ;;
    "\"${_option_git[0]}\"")
      install_git_config
      ;;
    "\"${_option_tmux[0]}\"")
      install_tmux_config
      ;;
    "\"${_option_vim[0]}\"")
      install_vim_config
      ;;
    "\"${_option_sh[0]}\"")
      install_bash_installers
      ;;
    "\"${_option_apt[0]}\"")
      install_apt_installers
      ;;
    "\"${_option_gitrepo[0]}\"")
      install_git_repositories
      ;;
    "\"${_option_brew[0]}\"")
      install_homebrew_installers
      ;;
    *)
      echo "...I have no idea what to do for \"$option\"..."
      ;;
  esac
done

#==============================================================================
# Post-install
#==============================================================================
if [[ $toInstall =~ "\"${_option_bash[0]}\"" ]]; then
  source ~/.bashrc
fi
