#!/bin/bash
set -e

tar -xf sed-*.tar.xz
pushd sed-*/

./configure --prefix=/usr --bindir=/bin
make
make html

if [ $LFS_TEST -eq 1 ]; then
  chown -Rv tester .
  su tester -c "PATH=$PATH make check"
fi

make install

install -d -m755           /usr/share/doc/sed-4.8
install -m644 doc/sed.html /usr/share/doc/sed-4.8

popd
rm -rf sed-*/
