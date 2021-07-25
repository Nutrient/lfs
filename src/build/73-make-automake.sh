#!/bin/bash
set -e

tar -xf automake-*.tar.xz

pushd automake-*/

sed -i "s/''/etags/" t/tags-lisp-space.sh

./configure --prefix=/usr --docdir=/usr/share/doc/automake-1.16.3

make

if [ $LFS_TEST -eq 1 ]; then
  make check || true
fi

make install

popd
rm -rf automake-*/
