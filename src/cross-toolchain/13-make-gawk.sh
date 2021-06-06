#!/bin/bash
set -e

tar -xf gawk-*.tar.xz
pushd gawk-*/

sed -i 's/extras//' Makefile.in

./configure       \
  --prefix=/usr   \
  --host=$LFS_TGT \
  --build=$(./config.guess)

make
make DESTDIR=$LFS install

popd

# Clean up
rm -rf gawk-*/
