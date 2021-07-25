#!/bin/bash
set -e

tar -xf diffutils-*.tar.xz
pushd diffutils-*/

./configure --prefix=/usr

make

if [ $LFS_TEST -eq 1 ]; then
  make check || true
fi

make install

popd
rm -rf diffutils-*/
