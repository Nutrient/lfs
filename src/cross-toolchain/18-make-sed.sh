#!/bin/bash
set -e

tar -xf sed-*.tar.xz
pushd sed-*/

./configure       \
  --prefix=/usr   \
  --host=$LFS_TGT \
  --bindir=/bin

make
make DESTDIR=$LFS install

popd
# Clean up
rm -rf sed-*/
