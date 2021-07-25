#!/bin/bash
set -e

tar -xf libtool-*.tar.xz
pushd libtool-*/

./configure --prefix=/usr

make

if [ $LFS_TEST -eq 1 ]; then
  make check || true
fi

make install

rm -fv /usr/lib/libltdl.a

popd
rm -rf libtool-*/
