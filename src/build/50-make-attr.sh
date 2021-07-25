#!/bin/bash
set -e

tar -xf attr-*.tar.gz
pushd attr-*/

./configure --prefix=/usr \
  --bindir=/bin           \
  --disable-static        \
  --sysconfdir=/etc       \
  --docdir=/usr/share/doc/attr-2.4.48

make

if [ $LFS_TEST -eq 1 ]; then
  make check || true
fi

make install

mv -v /usr/lib/libattr.so.* /lib
ln -sfv ../../lib/$(readlink /usr/lib/libattr.so) /usr/lib/libattr.so

popd
rm -rf attr-*/
