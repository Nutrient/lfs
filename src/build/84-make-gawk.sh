#!/bin/bash
set -e

tar -xf gawk-*.tar.xz
pushd gawk-*/

sed -i 's/extras//' Makefile.in
./configure --prefix=/usr

make

if [ $LFS_TEST -eq 1 ]; then
  make check || true
fi

make install

mkdir -v /usr/share/doc/gawk-5.1.0
cp    -v doc/{awkforai.txt,*.{eps,pdf,jpg}} /usr/share/doc/gawk-5.1.0

popd
rm -rf gawk-*/
