#!/bin/bash

URL="https://github.com/STMicroelectronics/OpenOCD.git"
cd /tmp
mkdir openocd
cd openocd
git clone $URL .
git submodule init
git submodule update

./bootstrap
./configure --prefix=/usr/local --enable-ftdi --enable-stlink --enable-jlinkn
make
make install

echo $(openocd --version)


