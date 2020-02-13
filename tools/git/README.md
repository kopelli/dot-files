 A `.clone` file represents a Git repo that should be cloned/fetched.
 The filename is just a unique identifier, and does not need to match part of the repo.
 The contents of the file is the `clone` URL.
 Ideally this is a read-only (i.e. HTTP) URL as the repo is meant to be fetched and merged.

 A `.install.sh` or `.install.ps1` file is a post-clone/fetch installation file.
 Since no Git hooks will be available on initial cloning of a repo, a custom script is the intended way to handle any manual steps necessary.
 No assumptions can be made about the environment that scripts are installed in.
 This includes the need for SUDO elevation, XDG environment variables, etc.
