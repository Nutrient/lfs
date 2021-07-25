#!/bin/bash
set -e

tar -xf iana-etc-*.tar.gz
pushd iana-etc-*/

cp services protocols /etc

popd

# Clean up
rm -rf iana-etc-*/
