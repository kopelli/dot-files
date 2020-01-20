# tap
A .tap file represents a Homebrew Tap.
The file name itself doesn't matter, as long as it has a `.tap` extension.
The contents of the file needs to be the repository name used in the command `brew tap <repo>`.

# brew
A .brew file represents the executables to be installed via Homebrew.
The contents of the file are ignored.
The file name must be the Bottle to install. E.g. `brew install <bottle>`

# cask
Casks are GUI tools that can be installed via Homebrew.
This is only supported on MacOS.
Like a .brew file, the contents of the file are ignored.
The name name is the cask install name. E.g. `brew cask install <cask>`
