#!/bin/bash
set -e

tar -xjf elfutils-*.tar.bz2
pushd elfutils-*/

./configure --prefix=/usr                \
            --disable-debuginfod         \
            --enable-libdebuginfod=dummy \
            --libdir=/lib

make

if [ $LFS_TEST -eq 1 ]; then
  make check || true
fi

make -C libelf install

install -vm644 config/libelf.pc /usr/lib/pkgconfig
rm /lib/libelf.a

popd
rm -rf elfutils-*/
