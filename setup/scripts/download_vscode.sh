#!/bin/bash

#export DOWNLOADED_PACKAGES_LOCATION
export PACKAGE_FILE_NAME="vscode"
export PACKAGE_EXTENSION=".deb"
export URL="https://go.microsoft.com/fwlink/?LinkID=760868"

source "$SCRIPTS_LOCATION/download_package.sh"
