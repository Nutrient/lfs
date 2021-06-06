#!/bin/bash
set -e

tar -xf Python-*.tar.xz
pushd Python-*/

./configure \
  --prefix=/usr \
  --enable-shared \
  --without-ensurepip

make
make install

popd

# Clean up
rm -rf Python-*/
