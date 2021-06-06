#!/bin/bash
set -e

tar -xf binutils-*.tar.xz
pushd binutils-*/

mkdir -v build
cd build

../configure                  \
  --prefix=/usr               \
  --build=$(../config.guess)  \
  --host=$LFS_TGT             \
  --disable-nls               \
  --enable-shared             \
  --disable-werror            \
  --enable-64-bit-bfd

make -j1
make -j1 DESTDIR=$LFS install
install -vm755 libctf/.libs/libctf.so.0.0.0 $LFS/usr/lib

popd

# Clean up
rm -rf binutils-*/
