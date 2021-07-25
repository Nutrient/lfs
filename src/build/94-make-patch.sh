#!/bin/bash
set -e

tar -xf patch-*.tar.xz
pushd patch-*/

./configure --prefix=/usr

make

if [ $LFS_TEST -eq 1 ]; then
  make check || true
fi

make install

popd
rm -rf patch-*/
