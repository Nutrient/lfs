#!/bin/bash
set -e

tar -xf inetutils-*.tar.xz

pushd inetutils-*/

./configure --prefix=/usr        \
            --localstatedir=/var \
            --disable-logger     \
            --disable-whois      \
            --disable-rcp        \
            --disable-rexec      \
            --disable-rlogin     \
            --disable-rsh        \
            --disable-servers

make

if [ $LFS_TEST -eq 1 ]; then
  make check || true
fi

make install
mv -v /usr/bin/{hostname,ping,ping6,traceroute} /bin
mv -v /usr/bin/ifconfig /sbin

popd
rm -rf inetutils-*/
