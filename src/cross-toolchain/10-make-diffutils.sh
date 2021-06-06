#!/bin/bash
set -e

tar -xf diffutils-*.tar.xz
pushd diffutils-*/

./configure       \
  --prefix=/usr   \
  --host=$LFS_TGT

make
make DESTDIR=$LFS install

popd

# Clean up
rm -rf diffutils-*/
