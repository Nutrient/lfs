#!/bin/bash
set -e

echo "Make Binutils Part 1"
sh $LFS/tools/1-make-binutils.sh > $LFS/logs/binutils-1 2>&1

echo "Make GCC Part 1"
sh $LFS/tools/2-make-gcc.sh > $LFS/logs/gcc-1 2>&1

echo "Make Linux API Headers"
sh $LFS/tools/3-make-linux-headers.sh > $LFS/logs/linux-headers 2>&1

echo "Make Glibc Part 1"
sh $LFS/tools/4-make-glibc.sh > $LFS/logs/glibc-1 2>&1

echo "Make Libstdc++ Part 1"
sh $LFS/tools/5-make-libstdc.sh > $LFS/logs/libstdc-1 2>&1

echo "Make M4 Part 1"
sh $LFS/tools/6-make-m4.sh > $LFS/logs/m4-1 2>&1

echo "Make Ncurses Part 1"
sh $LFS/tools/7-make-ncurses.sh > $LFS/logs/ncurses-1 2>&1

echo "Make Bash Part 1"
sh $LFS/tools/8-make-bash.sh > $LFS/logs/bash-1 2>&1

echo "Make Coreutils Part 1"
sh $LFS/tools/9-make-coreutils.sh > $LFS/logs/coreutils-1 2>&1

echo "Make Diffutils Part 1"
sh $LFS/tools/10-make-diffutils.sh > $LFS/logs/diffutils-1 2>&1

echo "Make File Part 1"
sh $LFS/tools/11-make-file.sh > $LFS/logs/file-1 2>&1

echo "Make Findutils Part 1"
sh $LFS/tools/12-make-findutils.sh > $LFS/logs/findutils-1 2>&1

echo "Make Gawk Part 1"
sh $LFS/tools/13-make-gawk.sh > $LFS/logs/gawk-1 2>&1

echo "Make Grep"
sh $LFS/tools/14-make-grep.sh > $LFS/logs/grep 2>&1

echo "Make Gzip"
sh $LFS/tools/15-make-gzip.sh > $LFS/logs/gzip 2>&1

echo "Make Make"
sh $LFS/tools/16-make-make.sh > $LFS/logs/make 2>&1

echo "Make Patch"
sh $LFS/tools/17-make-patch.sh > $LFS/logs/patch 2>&1

echo "Make Sed"
sh $LFS/tools/18-make-sed.sh > $LFS/logs/sed 2>&1

echo "Make Tar Part 1"
sh $LFS/tools/19-make-tar.sh > $LFS/logs/tar-1 2>&1

echo "Make XZ Part 1"
sh $LFS/tools/20-make-xz.sh > $LFS/logs/xz-1 2>&1

echo "Make XZ Part 1"
sh $LFS/tools/20-make-xz.sh > $LFS/logs/xz-1 2>&1

echo "Make Binutils Part 2"
sh $LFS/tools/21-make-binutils.sh > $LFS/logs/binutils-2 2>&1

echo "Make GCC Part 2"
sh $LFS/tools/22-make-gcc.sh > $LFS/logs/gcc-2 2>&1