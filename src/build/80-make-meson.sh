#!/bin/bash
set -e

tar -xf meson-*.tar.gz

pushd meson-*/

python3 setup.py build
python3 setup.py install --root=dest
cp -rv dest/* /

popd
rm -rf meson-*/
