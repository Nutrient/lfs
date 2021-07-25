#!/bin/bash
set -e

tar -xf bc-*.tar.xz
pushd bc-*/

PREFIX=/usr CC=gcc ./configure.sh -G -O3
make

if [ $LFS_TEST -eq 1 ]; then
  make test || true
fi

make install

popd
rm -rf bc-*/