#!/bin/bash
set -e

tar -xf zstd-*.tar.gz
pushd zstd-*/

make

if [ $LFS_TEST -eq 1 ]; then
  make check || true
fi

make prefix=/usr install

rm -v /usr/lib/libzstd.a
mv -v /usr/lib/libzstd.so.* /lib
ln -sfv ../../lib/$(readlink /usr/lib/libzstd.so) /usr/lib/libzstd.so

popd

rm -rf zstd-*/