#!/bin/bash

VERSION="12.2"

export DOWNLOADED_PACKAGES_LOCATION
export PACKAGE_FILE_NAME="gcc-arm-none-eabi"
export PACKAGE_EXTENSION="tar"
export URL="https://developer.arm.com/-/media/Files/downloads/gnu/${VERSION}.mpacbti-rel1/binrel/arm-gnu-toolchain-${VERSION}.mpacbti-rel1-aarch64-arm-none-eabi.tar.xz"

source "$SCRIPTS_LOCATION/download_package.sh"
