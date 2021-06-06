#!/bin/bash
set -e

# This commands run inside the chroot environment
# therefore $LFS dir location becomes /
cd sources/

echo "Create Essential Files"
sh /tools/23-create-essentials.sh > /logs/essentials 2>&1

echo "Make Libstdc++ Part 2"
sh /tools/24-make-libstdc.sh > /logs/libstdc-2 2>&1

echo "Make Gettext Part 1"
sh /tools/25-make-gettext.sh > /logs/gettext-1 2>&1

echo "Make Bison Part 1"
sh /tools/26-make-bison.sh > /logs/bison-1 2>&1

echo "Make Perl Part 1"
sh /tools/27-make-perl.sh > /logs/perl-1 2>&1

echo "Make Python Part 1"
sh /tools/28-make-python.sh > /logs/python-1 2>&1

echo "Make Texinfo Part 1"
sh /tools/29-make-texinfo.sh > /logs/texinfo-1 2>&1

echo "Make Util Linux"
sh /tools/30-make-util-linux.sh > /logs/util-linux 2>&1

# Clean up, remove unnessesary files

# Remove libtool.la files
find /usr/{lib,libexec} -name \*.la -delete
# Remove docs
rm -rf /usr/share/{info,man,doc}/*
