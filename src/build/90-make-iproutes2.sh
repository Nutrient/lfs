#!/bin/bash
set -e

tar -xf iproute2-*.tar.xz
pushd iproute2-*/

sed -i /ARPD/d Makefile
rm -fv man/man8/arpd.8
sed -i 's/.m_ipt.o//' tc/Makefile

make
make DOCDIR=/usr/share/doc/iproute2-5.10.0 install

popd
rm -rf iproute2-*/
