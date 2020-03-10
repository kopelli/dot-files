#!/bin/bash

_RELEASE="6.2.4"

_ARCHIVE_PATH="/tmp/powershell.tar.gz"
_INSTALL_PATH="/opt/microsoft/powershell/${_RELEASE}"
# Download the powershell '.tar.gz' archive
curl -L -o ${_ARCHIVE_PATH} https://github.com/PowerShell/PowerShell/releases/download/v${_RELEASE}/powershell-${_RELEASE}-linux-x64.tar.gz

# Create the target folder for "installation"
sudo mkdir -p ${_INSTALL_PATH}

# Expand the archive to the target folder
sudo tar zxf ${_ARCHIVE_PATH} -C ${_INSTALL_PATH}

# Set execution permissions
sudo chmod +x ${_INSTALL_PATH}/pwsh

# Create the symbolic link that points to pwsh
sudo ln -s ${_INSTALL_PATH}/pwsh /usr/bin/pwsh

