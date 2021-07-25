#!/bin/bash
set -e

tar -xf texinfo-*.tar.xz
pushd texinfo-*/

./configure --prefix=/usr
make

if [ $LFS_TEST -eq 1 ]; then
  make check || true
fi

make install

make TEXMF=/usr/share/texmf install-tex

popd
rm -rf texinfo-*/
