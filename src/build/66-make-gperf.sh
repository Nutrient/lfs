#!/bin/bash
set -e

tar -xf gperf-*.tar.gz

pushd gperf-*/
./configure --prefix=/usr --docdir=/usr/share/doc/gperf-3.1

make

if [ $LFS_TEST -eq 1 ]; then
  make -j1 check || true
fi

make install

popd
rm -rf gperf-*/
