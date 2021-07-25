#!/bin/bash
set -e

tar -xf sysvinit-*.tar.xz
pushd sysvinit-*/

patch -Np1 -i ../sysvinit-2.98-consolidated-1.patch

make
make install

popd
rm -rf sysvinit-*/
