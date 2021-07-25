#!/bin/bash
set -e

tar -xf flex-*.tar.gz
pushd flex-*/

./configure --prefix=/usr \
            --docdir=/usr/share/doc/flex-2.6.4 \
            --disable-static
make

if [ $LFS_TEST -eq 1 ]; then
  make check || true
fi

make install
ln -sv flex /usr/bin/lex

popd
rm -rf flex-*/