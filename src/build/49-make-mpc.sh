#!/bin/bash
set -e

tar -xf mpc-*.tar.gz
pushd mpc-*/

./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/mpc-1.2.1
make
make html

if [ $LFS_TEST -eq 1 ]; then
  make check || true
fi

make install
make install-html

popd
rm -rf mpc-*/