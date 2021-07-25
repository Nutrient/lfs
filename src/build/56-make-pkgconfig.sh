#!/bin/bash
set -e

tar -xf pkg-config-*.tar.gz
pushd pkg-config-*/

./configure --prefix=/usr              \
            --with-internal-glib       \
            --disable-host-tool        \
            --docdir=/usr/share/doc/pkg-config-0.29.2
make

if [ $LFS_TEST -eq 1 ]; then
  make check || true
fi

make install

popd
rm -rf pkg-config-*/
