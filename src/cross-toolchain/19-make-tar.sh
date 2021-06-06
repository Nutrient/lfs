#!/bin/bash
set -e

tar -xf tar-*.tar.xz
pushd tar-*/

./configure                         \
  --prefix=/usr                     \
  --host=$LFS_TGT                   \
  --build=$(build-aux/config.guess) \
  --bindir=/bin

make
make DESTDIR=$LFS install

popd

# Clean up
rm -rf tar-*/
