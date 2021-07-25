#!/bin/bash
set -e

tar -xf findutils-*.tar.xz
pushd findutils-*/

./configure --prefix=/usr --localstatedir=/var/lib/locate
make

if [ $LFS_TEST -eq 1 ]; then
  chown -Rv tester .
  su tester -c "PATH=$PATH make check"
fi

make install
mv -v /usr/bin/find /bin
sed -i 's|find:=${BINDIR}|find:=/bin|' /usr/bin/updatedb

popd
rm -rf findutils-*/
