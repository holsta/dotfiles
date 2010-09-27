#!/bin/sh
#
# Automate gcc upgrade.

# Firstly, gcc4 must be compiled with the existing compiler:
rm -rf /usr/obj/*
cd /usr/src/share/mk && make install
cd /usr/src/gnu/usr.bin/cc
make obj && make depend && make && make install

# Secondly, gcc4 must be rebuilt with itself:
rm -rf /usr/obj/*
cd /usr/src/usr.bin/cpp
make obj && make && make install
cd /usr/src/gnu/usr.bin/cc
make obj && make depend && make && make install

# Thirdly, libstdc++-v3 must be installed after removing the old C++ headers:
rm -rf /usr/include/g++/*
cd /usr/src/gnu/lib/libstdc++-v3
make obj && make includes && make depend && make && make install

# And lastly the entire system rebuilt with the usual procedure documented in
# release(8)
echo "Now, build a release, damn it."
