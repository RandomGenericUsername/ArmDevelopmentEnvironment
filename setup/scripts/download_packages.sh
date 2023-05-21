#!/bin/bash

export SCRIPTS_PERSMISSIONS
export DOWNLOADED_PACKAGES_LOCATION
export SCRIPTS_LOCATION

source "./$SCRIPTS_LOCATION/download_arm_toolchain.sh"
source "./$SCRIPTS_LOCATION/download_vscode.sh"
source "./$SCRIPTS_LOCATION/download_openocd.sh"
