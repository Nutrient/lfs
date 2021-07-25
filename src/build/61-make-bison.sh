#!/bin/bash
set -e

tar -xf bison-*.tar.xz
pushd bison-*/

./configure --prefix=/usr --docdir=/usr/share/doc/bison-3.7.5

make

if [ $LFS_TEST -eq 1 ]; then
  make check || true
fi

make install

popd
rm -rf bison-*/
