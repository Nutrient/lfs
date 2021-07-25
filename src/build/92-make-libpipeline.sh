#!/bin/bash
set -e

tar -xf libpipeline-*.tar.gz
pushd libpipeline-*/

./configure --prefix=/usr
make

if [ $LFS_TEST -eq 1 ]; then
  make check || true
fi

make install

popd
rm -rf libpipeline-*/
