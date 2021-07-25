#!/bin/bash
set -e

tar -xf make-*.tar.gz
pushd make-*/

./configure --prefix=/usr

make

if [ $LFS_TEST -eq 1 ]; then
  make check || true
fi

make install

popd
rm -rf make-*/
