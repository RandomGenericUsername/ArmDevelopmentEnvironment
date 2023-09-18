#!/bin/bash


cd /opt
git clone https://github.com/stlink-org/stlink.git
cd stlink
mkdir -p /build
cd build
cmake ..
make
make install
ldconfig
cd -