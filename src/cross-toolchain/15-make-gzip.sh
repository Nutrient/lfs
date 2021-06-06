#!/bin/bash
set -e

tar -xf gzip-*.tar.xz
pushd gzip-*/

./configure       \
  --prefix=/usr   \
  --host=$LFS_TGT

make
make DESTDIR=$LFS install
mv -v $LFS/usr/bin/gzip $LFS/bin

popd

# Clean up
rm -rf gzip-*/
