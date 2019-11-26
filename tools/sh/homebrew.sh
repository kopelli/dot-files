#!/bin/bash

# Check for Homebrew
if [[ ! -n $(which brew) ]]; then
  echo "...Installing Homebrew..."
  if [[ "$(uname -s)" = "Darwin" ]]; then
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  elif [[ "$(uname -s)" = "Linux" ]]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh)"
  else
    echo "I have no clue how to handle \"$(uname -s)\""
  fi
fi
exit 0