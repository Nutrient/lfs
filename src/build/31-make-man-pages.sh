#!/bin/bash
set -e

tar -xf man-pages-*.tar.xz
pushd man-pages-*/

make install

popd
# Clean up
rm -rf man-pages-*/
