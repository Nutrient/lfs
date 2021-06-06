#!/bin/bash
set -e

tar -xf grep-*.tar.xz

pushd grep-*/
./configure       \
  --prefix=/usr   \
  --host=$LFS_TGT \
  --bindir=/bin

make
make DESTDIR=$LFS install

popd

# Clean up
rm -rf grep-*/
