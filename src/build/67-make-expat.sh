#!/bin/bash
set -e

tar -xf expat-*.tar.xz

pushd expat-*/
./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/expat-2.2.10

make

if [ $LFS_TEST -eq 1 ]; then
  make check || true
fi

make install

install -v -m644 doc/*.{html,png,css} /usr/share/doc/expat-2.2.10

popd
rm -rf expat-*/
