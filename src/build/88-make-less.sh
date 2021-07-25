#!/bin/bash
set -e

tar -xf less-*.tar.gz
pushd less-*/

./configure --prefix=/usr --sysconfdir=/etc

make
make install

popd
rm -rf less-*/
