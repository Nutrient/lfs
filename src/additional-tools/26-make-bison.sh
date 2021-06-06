#!/bin/bash
set -e

tar -xf bison-*.tar.xz
pushd bison-*/

./configure \
  --prefix=/usr \
  --docdir=/usr/share/doc/bison-3.7.5

make
make install

popd

# Clean up
rm -rf bison-*/
