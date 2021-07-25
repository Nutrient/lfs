#!/bin/bash
set -e

tar -xf libffi-*.tar.gz

pushd libffi-*/

./configure --prefix=/usr --disable-static --with-gcc-arch=native

make

if [ $LFS_TEST -eq 1 ]; then
  make check || true
fi

make install

popd
rm -rf libffi-*/
