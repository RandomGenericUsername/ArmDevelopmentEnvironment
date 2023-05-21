#!bin/bash

cd /tmp/downloaded_packages/openocd

./bootstrap
./configure --prefix=/usr/bin --enable-ftdi --enable-stlink --enable-jlinkn
make
make install

echo $(openocd --version)


