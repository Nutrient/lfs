#!/bin/bash
set -e

tar -xf tar-*.tar.xz
pushd tar-*/

FORCE_UNSAFE_CONFIGURE=1  \
./configure --prefix=/usr \
            --bindir=/bin

make

if [ $LFS_TEST -eq 1 ]; then
  make check || true
fi

make install
make -C doc install-html docdir=/usr/share/doc/tar-1.34

popd
rm -rf tar-*/
