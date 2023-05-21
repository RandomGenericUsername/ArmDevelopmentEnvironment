#!/bin/bash


cd /tmp/downloaded_packages/gcc-arm-none-eabi

VERSION=$1

echo "Generating debian package..."
mkdir gcc-arm-none-eabi
mkdir gcc-arm-none-eabi/DEBIAN
mkdir gcc-arm-none-eabi/usr
echo "Package: gcc-arm-none-eabi"          >  gcc-arm-none-eabi/DEBIAN/control
echo "Version: $VERSION"                   >> gcc-arm-none-eabi/DEBIAN/control
echo "Architecture: amd64"                 >> gcc-arm-none-eabi/DEBIAN/control
echo "Maintainer: maintainer"              >> gcc-arm-none-eabi/DEBIAN/control
echo "Description: Arm Embedded toolchain" >> gcc-arm-none-eabi/DEBIAN/control
mv gcc-arm-none-eabi-*/* gcc-arm-none-eabi/usr/
dpkg-deb --build --root-owner-group gcc-arm-none-eabi

echo "Installing..."
apt install ./gcc-arm-none-eabi.deb -y --allow-downgrades

echo "Removing temporary files..."
rm -r gcc-arm-none-eabi*
arm-none-eabi-gcc --version

echo "Done."