#!/bin/bash
set -e

tar -xf file-*.tar.gz
pushd file-*/
mkdir -v build

pushd build
../configure            \
  --disable-bzlib       \
  --disable-libseccomp  \
  --disable-xzlib       \
  --disable-zlib
make
popd

./configure             \
  --prefix=/usr         \
  --host=$LFS_TGT       \
  --build=$(./config.guess)

make FILE_COMPILE=$(pwd)/build/src/file
make DESTDIR=$LFS install

popd

# Clean up
rm -rf file-*/
