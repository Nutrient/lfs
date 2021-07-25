#!/bin/bash
set -e

tar -xf check-*.tar.gz

pushd check-*/

./configure --prefix=/usr --disable-static
make

if [ $LFS_TEST -eq 1 ]; then
  make check || true
fi

make docdir=/usr/share/doc/check-0.15.2 install

popd
rm -rf check-*/
