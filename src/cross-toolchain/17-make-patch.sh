#!/bin/bash
set -e

tar -xf patch-*.tar.xz
pushd patch-*/

./configure       \
  --prefix=/usr   \
  --host=$LFS_TGT \
  --build=$(build-aux/config.guess)

make
make DESTDIR=$LFS install

popd
# Clean up
rm -rf patch-*/
