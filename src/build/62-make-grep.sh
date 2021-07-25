#!/bin/bash
set -e

tar -xf grep-*.tar.xz
pushd grep-*/

./configure --prefix=/usr --bindir=/bin
make

if [ $LFS_TEST -eq 1 ]; then
  make check || true
fi

make install

popd
rm -rf grep-*/
