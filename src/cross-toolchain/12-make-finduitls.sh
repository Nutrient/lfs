#!/bin/bash
set -e

tar -xf findutils-*.tar.xz
pushd findutils-*/

./configure       \
  --prefix=/usr   \
  --host=$LFS_TGT \
  --build=$(build-aux/config.guess)

make
make DESTDIR=$LFS install
mv -v $LFS/usr/bin/find $LFS/bin
sed -i 's|find:=${BINDIR}|find:=/bin|' $LFS/usr/bin/updatedb

popd

# Clean up
rm -rf findutils-*/
