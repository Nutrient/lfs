#!/bin/bash
set -e

tar -xf kbd-*.tar.xz
pushd kbd-*/

patch -Np1 -i ../kbd-2.4.0-backspace-1.patch
sed -i '/RESIZECONS_PROGS=/s/yes/no/' configure
sed -i 's/resizecons.8 //' docs/man/man8/Makefile.in
./configure --prefix=/usr --disable-vlock
make

if [ $LFS_TEST -eq 1 ]; then
  make check || true
fi

make install

popd
rm -rf kbd-*/
