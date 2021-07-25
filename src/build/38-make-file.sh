#!/bin/bash
set -e

tar -xf file-*.tar.gz
pushd file-*/

./configure --prefix=/usr
make

if [ $LFS_TEST -eq 1 ]; then
  make check || true
fi

make install

popd
rm -rf file-*/
