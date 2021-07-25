#!/bin/bash
set -e

tar -xf binutils-*.tar.xz
pushd binutils-*/

expect -c "spawn ls"
sed -i '/@\tincremental_copy/d' gold/testsuite/Makefile.in
mkdir -v build
cd build
../configure --prefix=/usr  \
  --enable-gold             \
  --enable-ld=default       \
  --enable-plugins          \
  --enable-shared           \
  --disable-werror          \
  --enable-64-bit-bfd       \
  --with-system-zlib

make tooldir=/usr

if [ $LFS_TEST -eq 1 ]; then
  make -k check || true
fi

make tooldir=/usr install

rm -fv /usr/lib/lib{bfd,ctf,ctf-nobfd,opcodes}.a

popd
rm -rf binutils-*/
