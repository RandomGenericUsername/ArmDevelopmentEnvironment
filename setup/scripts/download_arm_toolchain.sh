#!/bin/bash

#export DOWNLOADED_PACKAGES_LOCATION
export PACKAGE_FILE_NAME="gcc-arm-none-eabi"
export PACKAGE_EXTENSION=".tar"
export URL="https://developer.arm.com/-/media/Files/downloads/gnu/${GCC_ARM_NONE_EABI_VERSION}.mpacbti-rel1/binrel/arm-gnu-toolchain-${GCC_ARM_NONE_EABI_VERSION}.mpacbti-rel1-${TARGET_ARCHITECTURE}-arm-none-eabi.tar.xz"
source "$SCRIPTS_LOCATION/download_package.sh"
