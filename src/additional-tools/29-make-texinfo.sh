#!/bin/bash
set -e

tar -xf texinfo-*.tar.xz
pushd texinfo-*/

./configure --prefix=/usr

make
make install

popd
# Clean up
rm -rf texinfo-*/
