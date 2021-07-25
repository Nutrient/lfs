#!/bin/bash
set -e

tar -xf autoconf-*.tar.xz
pushd autoconf-*/

./configure --prefix=/usr

make

if [ $LFS_TEST -eq 1 ]; then
  make check || true
fi

make install

popd
rm -rf autoconf-*/
