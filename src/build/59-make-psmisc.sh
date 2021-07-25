#!/bin/bash
set -e

tar -xf psmisc-*.tar.xz
pushd psmisc-*/

./configure --prefix=/usr
make
make install

mv -v /usr/bin/fuser   /bin
mv -v /usr/bin/killall /bin

popd
rm -rf psmisc-*/
