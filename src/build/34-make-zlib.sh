#!/bin/bash
set -e

tar -xf zlib-*.tar.xz
pushd zlib-*/

./configure \
  --prefix=/usr

make

if [ $LFS_TEST -eq 1 ]; then
    make check || true
fi

make install

mv -v /usr/lib/libz.so.* /lib
ln -sfv ../../lib/$(readlink /usr/lib/libz.so) /usr/lib/libz.so
rm -fv /usr/lib/libz.a

popd
rm -rf zlib-*/
