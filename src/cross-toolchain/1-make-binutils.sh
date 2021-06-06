#!/bin/bash
set -e

tar -xf binutils-*.tar.xz
pushd binutils-*/
mkdir -v build
cd build

../configure                      \
  --prefix=$LFS/tools             \
  --with-sysroot=$LFS             \
  --target=$LFS_TGT               \
  --disable-nls--disable-werror

make -j1
make install -j1
popd

# Clean up
rm -rf binutils-*/
