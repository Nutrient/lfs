#!/bin/bash
set -e

tar -xf xz-*.tar.xz
pushd xz-*/

./configure         \
  --prefix=/usr     \
  --disable-static  \
  --docdir=/usr/share/doc/xz-5.2.5
make

if [ $LFS_TEST -eq 1 ]; then
  make check || true
fi

make install

mv -v /usr/bin/{lzma,unlzma,lzcat,xz,unxz,xzcat} /bin
mv -v /usr/lib/liblzma.so.* /lib
ln -svf ../../lib/$(readlink /usr/lib/liblzma.so) /usr/lib/liblzma.so

popd

rm -rf xz-*/
