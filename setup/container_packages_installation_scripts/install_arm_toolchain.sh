#!/bin/bash


if [ $TARGET_ARCHITECTURE == "x86_64" ]; then
    VERSION="amd64"
    elif [ $TARGET_ARCHITECTURE == "aarch64" ]; then
    VERSION="aarch64"
else
    echo "fatal error"
    exit 1
fi


cd ${DOWNLOADED_PACKAGES_LOCATION}/gcc-arm-none-eabi

echo "Generating debian package..."
mkdir gcc-arm-none-eabi
mkdir gcc-arm-none-eabi/DEBIAN
mkdir gcc-arm-none-eabi/usr
echo "Package: gcc-arm-none-eabi"          >  gcc-arm-none-eabi/DEBIAN/control
echo "Version: $GCC_ARM_NONE_EABI_VERSION" >> gcc-arm-none-eabi/DEBIAN/control
echo "Architecture: $VERSION"              >> gcc-arm-none-eabi/DEBIAN/control
echo "Maintainer: maintainer"              >> gcc-arm-none-eabi/DEBIAN/control
echo "Description: Arm Embedded toolchain" >> gcc-arm-none-eabi/DEBIAN/control
find . -maxdepth 1 ! -name 'gcc-arm-none-eabi' ! -name '.' -exec mv -t gcc-arm-none-eabi/usr/ {} +
dpkg-deb --build --root-owner-group gcc-arm-none-eabi
echo "Installing..."
dpkg -i gcc-arm-none-eabi.deb
arm-none-eabi-gcc --version
echo "Removing temporary files..."
#rm -r gcc-arm-none-eabi*
echo "Done."