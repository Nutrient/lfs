#!/bin/bash
set -e

tar -xf expect*.tar.gz
pushd expect*/

./configure --prefix=/usr \
  --with-tcl=/usr/lib     \
  --enable-shared         \
  --mandir=/usr/share/man \
  --with-tclinclude=/usr/include

make

if [ $LFS_TEST -eq 1 ]; then
  make test || true
fi

make install
ln -svf expect5.45.4/libexpect5.45.4.so /usr/lib

popd
rm -rf expect*/
