#!/bin/bash

_menu_text="Select all that you would like to install\nPress [Enter] to continue installation"
_option_bash=('BASH' ".bashrc" ON)
_option_git=('GIT' "Git configuration" ON)
_option_tmux=('TMUX' "TMUX configuration" ON)
_option_vim=('VIM' "Vim config & plugins" ON)

read _height _width < <(stty size)
_optionCount=4 # This should be how many `_option...` variables are above
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
  "${_option_vim[@]}" 3>&1 1>&2 2>&3)

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
    install_dir=${install_dir:-$(pwd)}
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
      ln -fs ${install_dir}/_gitconfig ~/.gitconfig
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
    *)
      echo "...I have no idea what to do for \"$option\"..."
      ;;
  esac
done

if [[ $toInstall =~ "\"${_option_bash[0]}\"" ]]; then
  source ~/.bashrc
fi
