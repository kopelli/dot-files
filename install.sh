#!/bin/bash

#==============================================================================
# Menu configuration
#==============================================================================
_menu_text="Select all that you would like to install\nPress [Enter] to continue installation"
_option_bash=('BASH' ".bashrc, environment, and scripts" ON)
_option_git=('GIT' "Git configuration" ON)
_option_tmux=('TMUX' "TMUX configuration" ON)
_option_vim=('VIM' "Vim config & plugins" ON)
_option_sh=('sh' "Bash script installers" ON)
_option_apt=('apt' "APT packages" ON)
_option_gitrepo=('gitrepos' "Direct Git repos" ON)
_option_brew=('brew' "Homebrew/Linuxbrew" ON)
_optionCount=8 # This should be how many `_option...` variables are above

# Color output reminder...
# Need to use `echo -e "..."`
# Escape sequence is `\e[{CODE;}COLORm`
#
# Color         | FG | BG
# -----         | -- | --
# Black         | 30 | 40
# Red           | 31 | 41
# Green         | 32 | 42
# Yellow        | 33 | 43
# Blue          | 34 | 44
# Magenta       | 35 | 45
# Cyan          | 36 | 46
# Light Gray    | 37 | 47
# Gray          | 90 | 100
# Light Red     | 91 | 101
# Light Green   | 92 | 102
# Light Yellow  | 93 | 103
# Light Blue    | 94 | 104
# Light Magenta | 95 | 105
# Light Cyan    | 96 | 106
# White         | 97 | 107
#
# Code | Description
# ---- | -----------
#  0   | Reset/Normal
#  1   | Bold text
#  2   | Faint text
#  3   | Italics
#  4   | Underlined text
_color_BLUE="\e[34m"
_color_GRAY="\e[90m"
_color_GREEN="\e[32m"
_color_MAGENTA="\e[35m"
_color_RED="\e[31m"
_color_RESET="\e[0m"
_color_YELLOW="\e[33m"

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

    echo -e "${_color_GRAY}Updating apt...${_color_RESET}"
    $SUDO apt-get -qq update
    if [[ -d "${APT_DIR}" ]]; then
      local PACKAGES=''
      for FILE in $("ls" -1 "${APT_DIR}/"*.apt) ; do
        PACKAGES="$PACKAGES $(basename "$FILE" .apt)"
      done

      if [[ "$PACKAGES" != "" ]]; then
        echo -e "${_color_GRAY}>>$SUDO apt-get -q install ${_color_BLUE}${PACKAGES}${_color_GRAY}...${_color_RESET}"
        $SUDO apt-get -q install $PACKAGES
        echo "          ...DONE!"
      fi
    else
      echo -e "${_color_RED}Expected directory could not be found${_color_RESET}"
    fi
  else
    echo -e "${_color_RED}Apt is not installed, skipping...${_color_RESET}"
  fi
}

function install_bash() {
  echo -e "Installing ${_color_MAGENTA}bash configurations${_color_RESET}..."
  ln -fs ${install_dir}/.bash/bashrc ~/.bashrc
  ln -fs ${install_dir}/.bash/bash_profile ~/.bash_profile
  ln -fs ${install_dir}/.profile ~/.profile

  echo -e "Installing ${_color_MAGENTA}bash executables${_color_RESET}..."
  local BIN_DIR="${install_dir}/.bash/bin"
  if [[ -d "${BIN_DIR}" ]]; then
    # Use this trick to determine if we need to prefix the "sudo" command"
    # Taken from https://stackoverflow.com/a/21622456/6504
    local SUDO=''
    if (( $EUID != 0 )); then
      SUDO='sudo'
    fi

    for FILE in $("ls" -1 "${BIN_DIR}/"*) ; do
      EXE_NAME="$(basename "$FILE")"
      LINK_TARGET="/usr/local/bin/${EXE_NAME}"
      echo -e "${_color_GRAY}ln ${_color_GREEN}${FILE} ${_color_BLUE}${LINK_TARGET}${_color_RESET}"
      $SUDO ln -fs ${FILE} ${LINK_TARGET}
    done
  fi
}

function install_bash_installers() {
  local SH_DIR="${install_dir}/tools/sh"
  if [[ -d "${SH_DIR}" ]]; then
    echo -e "${_color_MAGENTA}Executing shell script installers...${_color_RESET}"
    for FILE in $("ls" -1 "${SH_DIR}/"*.sh) ; do
      FILE="./$(realpath --relative-to="${PWD}" "$FILE")"
      echo -e "${_color_GRAY}Executing ${_color_RESET}\"${_color_GREEN}${FILE}${_color_RESET}\"${_color_GRAY}...${_color_RESET}"
      bash "$FILE"
    done
  else
    echo -e "${_color_RED}Cannot execute shell script installers. Expected directory does not exist!${_color_RESET}"
  fi
}

function install_git_config() {
  echo -e "Installing ${_color_MAGENTA}git configuration${_color_RESET}..."
  ln -fs ${install_dir}/.git-config/config ~/.gitconfig
  ln -fs ${install_dir}/.git-config/ ~/
}

function install_git_repositories() {
  XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}
  local GIT_REPO_DIR="${install_dir}/tools/git"
  if [[ $(which git) ]]; then
    echo -e "${_color_GRAY}Starting to clone git repos...${_color_RESET}"
    if [[ -d "${GIT_REPO_DIR}" ]]; then
      for FILE in $("ls" -1 "${GIT_REPO_DIR}/"*.clone) ; do
        local REPO_FILE_NAME="$(basename "$FILE" .clone)"
        local CLONE_PATH=$XDG_DATA_HOME/cloned-repos/${REPO_FILE_NAME}
        if [[ ! -d "$CLONE_PATH" ]]; then
          echo -e "${_color_YELLOW}Need to make the git clone directory \"${_color_GREEN}$CLONE_PATH${_color_YELLOW}\"${_color_RESET}"
          mkdir -p "$CLONE_PATH"
          git -C "$CLONE_PATH" init -q
          git -C "$CLONE_PATH" config remote.origin.url "$("cat" $FILE)"
          git -C "$CLONE_PATH" config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
          git -C "$CLONE_PATH" config core.autocrlf "false"
        else
          echo -e "${_color_YELLOW}Updating \"${_color_BLUE}${REPO_FILE_NAME}${_color_YELLOW}\"${_color_RESET}"
        fi

        echo -e "${_color_GRAY}>>git -C \"${_color_GREEN}${CLONE_PATH}${_color_GRAY}\" fetch origin master:origin/master --tags --force${_color_RESET}"
        git -C "$CLONE_PATH" fetch origin master:origin/master --tags --force
        git -C "$CLONE_PATH" reset --hard "origin/master"

        echo -e "${_color_GRAY}>>${GIT_REPO_DIR}/${REPO_FILE_NAME}.install.sh${_color_RESET}"
        bash "${GIT_REPO_DIR}/${REPO_FILE_NAME}.install.sh"
        echo "          ...DONE"
      done
    fi
  else
    echo -e "${_color_RED}Git is not available, skipping...${_color_RESET}"
  fi
}

function install_homebrew_installers() {
  local BREW_DIR="${install_dir}/tools/brew"
  if [[ $(which brew) ]]; then
    echo -e "${_color_GRAY}Starting to brew install some packages...${_color_RESET}"
    if [[ -d "${BREW_DIR}" ]]; then
      for TAP in $("ls" -1 "${BREW_DIR}/"*.tap) ; do
        local TAP_REPO=$("cat" $TAP)
        TAP_REPO="${TAP_REPO/$'\r'/}"
        if [[ "$(brew tap | grep ${TAP_REPO})" == "" ]]; then
          echo -e "${_color_GRAY}>>brew tap ${_color_BLUE}$TAP_REPO${_color_RESET}"
          brew tap $TAP_REPO
          echo "          ...DONE"
        fi
      done

      local BOTTLES=''
      for FILE in $("ls" -1 "${BREW_DIR}/"*.brew) ; do
        BOTTLES="$BOTTLES $(basename "$FILE" .brew)"
      done
      if [[ "$BOTTLES" != "" ]]; then
        echo -e "${_color_GRAY}>>brew install ${_color_BLUE}$BOTTLES${_color_GRAY}...${_color_RESET}"
        brew install $BOTTLES
        echo "          ...DONE"
      fi

      # Casks are MacOS only...
      if [[ "$osname" == "Darwin" ]]; then
        local CASKS=''
        for FILE in $("ls" -1 "${BREW_DIR}/"*.cask) ; do
          CASKS="$CASKS $(basename "$FILE" .cask)"
        done
        if [[ "$CASKS" != "" ]]; then
          echo -e "${_color_GRAY}>>brew cask install ${_color_BLUE}$CASKS${_color_GRAY}...${_color_RESET}"
          brew cask install $CASKS
          echo "          ...DONE"
        fi
      fi
    fi
  else
    echo -e "${_color_RED}Brew is not installed, skipping...${_color_RESET}"
  fi
}

function install_tmux_config() {
  echo -e "Installing ${_color_MAGENTA}tmux configuration${_color_RESET}..."
  ln -fs ${install_dir}/_tmux.conf ~/.tmux.conf
}

function install_vim_config() {
  echo -e "Installing ${_color_MAGENTA}vim configuration${_color_RESET}..."
  ln -fs ${install_dir}/.vim/_vimrc ~/.vimrc
  ln -fs ${install_dir}/.vim/gvimrc ~/.gvimrc
  ln -fs ${install_dir}/.vim/ ~/

  echo -e "Installing ${_color_MAGENTA}vim plugins${_color_RESET}..."
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
    echo -e "${_color_RED}...not sure what to do on \"${_color_GREEN}$osname${_color_RED}\"...${_color_RESET}"
esac

# Reset the color output before performing anything else...
echo -ne "${_color_RESET}"

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
    echo -e "${_color_YELLOW}We're in a git repo, so assume this is the install directory${_color_RESET}"
    # TODO: Loop through remotes and make sure one of them matches
    # TODO: Find the root of the git repo
    install_dir="$(pwd)"
else
    echo -e "${_color_RED}Where do you want to download the repo to?"
    echo -e "The 'dot-files' directory will be created automatically${_color_RESET}"
    read -p "($(pwd)): " install_dir </dev/tty
    install_dir=${install_dir:-$(pwd)}/dot-files
    git clone --depth 1 --no-tags --origin "upstream" https://github.com/kopelli/dot-files "${install_dir}"
    git -C "${install_dir}" remote set-url --push "upstream" "DISALLOWED"
fi

#==============================================================================
# Perform installs
#==============================================================================

echo -e "${_color_GRAY}You are running ${_color_RESET}\"${_color_GREEN}$osname${_color_RESET}\""
echo -e "Install directory is \"${_color_GREEN}${install_dir}${_color_RESET}\""
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
