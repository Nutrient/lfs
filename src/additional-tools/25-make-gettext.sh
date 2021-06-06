#!/bin/bash
set -e

tar -xf gettext-*.tar.xz
pushd gettext-*/

./configure --disable-shared

make
cp -v gettext-tools/src/{msgfmt,msgmerge,xgettext} /usr/bin

popd

# Clean up
rm -rf gettext-*/
