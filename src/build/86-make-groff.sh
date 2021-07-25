#!/bin/bash
set -e

tar -xf groff-*.tar.gz
pushd groff-*/

PAGE=letter ./configure --prefix=/usr
make -j1
make install

popd
rm -rf groff-*/
