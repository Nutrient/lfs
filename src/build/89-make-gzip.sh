#!/bin/bash
set -e

tar -xf gzip-*.tar.xz
pushd gzip-*/

./configure --prefix=/usr
make

if [ $LFS_TEST -eq 1 ]; then
  make check || true
fi

make install
mv -v /usr/bin/gzip /bin

popd
rm -rf gzip-*/
