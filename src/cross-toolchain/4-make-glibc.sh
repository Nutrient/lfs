#!/bin/bash
set -e

tar -xf glibc-*.tar.xz

pushd glibc-*/

case $(uname -m) in
i?86)
  ln -sfv ld-linux.so.2 $LFS/lib/ld-lsb.so.3
  ;;
x86_64)
  ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64
  ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64/ld-lsb-x86-64.so.3
  ;;
esac

patch -Np1 -i ../glibc-*-fhs-1.patch
mkdir -v build
cd build
../configure                          \
  --prefix=/usr                       \
  --host=$LFS_TGT                     \
  --build=$(../scripts/config.guess)  \
  --enable-kernel=3.2                 \
  --with-headers=$LFS/usr/include     \
  libc_cv_slibdir=/lib

make -j1
make -j1 DESTDIR=$LFS install

popd

# Perform sanity check

echo 'int main(){}' > dummy.c
$LFS_TGT-gcc dummy.c
readelf -l a.out | grep '/ld-linux'
rm -v dummy.c a.out

$LFS/tools/libexec/gcc/$LFS_TGT/10.2.0/install-tools/mkheaders

# Clean up
rm -rf glibc-*/
