#!/bin/bash
set -e

tar -xf openssl-*.tar.gz
pushd openssl-*/

./config --prefix=/usr         \
         --openssldir=/etc/ssl \
         --libdir=lib          \
         shared                \
         zlib-dynamic

make

if [ $LFS_TEST -eq 1 ]; then
  make test || true
fi

sed -i '/INSTALL_LIBS/s/libcrypto.a libssl.a//' Makefile
make MANSUFFIX=ssl install
mv -v /usr/share/doc/openssl /usr/share/doc/openssl-1.1.1j
cp -vfr doc/* /usr/share/doc/openssl-1.1.1j

popd
rm -rf openssl-*/
