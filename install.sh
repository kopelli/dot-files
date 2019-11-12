#!/bin/bash

echo "You are about to set up all dot files."
read -p "Proceed (y/N)❓ " answer </dev/tty

if ! [[ "${answer:-N}" =~ [yY] ]]; then
    exit 0;
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


echo "Installing to ${install_dir}"

echo "Installing bash..."
rm -rf ~/.bashrc
ln -s ${install_dir}/.bash/bashrc ~/.bashrc

echo "Installing git..."
rm -rf ~/.gitconfig
rm -rf ~/.git-commit-template
ln -s ${install_dir}/_gitconfig ~/.gitconfig
ln -s ${install_dir}/_git-commit-template ~/.git-commit-template

echo "Installing tmux..."
rm -rf ~/.tmux.conf
ln -s ${install_dir}/_tmux.conf ~/.tmux.conf

echo "Installing vim..."
rm -rf ~/.vimrc
rm -rf ~/.vim
ln -s ${install_dir}/.vim/_vimrc ~/.vimrc
ln -s ${install_dir}/.vim ~/.vim

echo "Installing vim plugins..."
</dev/tty vim +PlugInstall +qall
source ~/.bashrc