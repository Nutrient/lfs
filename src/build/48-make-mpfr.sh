#!/bin/bash
set -e

tar -xf mpfr-*.tar.xz
pushd mpfr-*/

./configure --prefix=/usr        \
            --disable-static     \
            --enable-thread-safe \
            --docdir=/usr/share/doc/mpfr-4.1.0
make
make html

if [ $LFS_TEST -eq 1 ]; then
  make check || true
fi

make install
make install-html

popd
rm -rf mpfr-*/