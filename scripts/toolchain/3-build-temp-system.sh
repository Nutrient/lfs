#!/bin/bash

cd sources

tar -xf gcc-*.tar.xz
pushd gcc-*/
ln -s gthr-posix.h libgcc/gthr-default.h
mkdir -v build && cd build
time {  ../libstdc++-v3/configure             \
        CXXFLAGS="-g -O2 -D_GNU_SOURCE"       \
        --prefix=/usr                         \
        --disable-multilib                    \
        --disable-nls                         \
        --host=$(uname -m)-lfs-linux-gnu      \
        --disable-libstdcxx-pch               \
        && make && make install;              } > /logs/libstdc-2 2>&1
popd
# Clean up
rm -rf gcc-*/

tar -xf gettext-*.tar.xz

pushd gettext-*/
time {  ./configure --disable-shared && make; }
cp -v gettext-tools/src/{msgfmt,msgmerge,xgettext} /usr/bin ) > /logs/gettext 2>&1
popd
rm -rf sources/gettext-*/