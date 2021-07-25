#!/bin/bash
set -e

# This commands run inside the chroot environment
# therefore $LFS dir location becomes /
cd sources/

echo "Make Man Pages"
sh /tools/31-make-man-pages.sh > /logs/man-pages 2>&1

echo "Make Iana-etc"
sh /tools/32-make-iana-etc.sh > /logs/iana-etc 2>&1

echo "Make Glibc Part 2 & Locales"
sh /tools/33-make-glibc.sh > /logs/glibc-2 2>&1

echo "Make Zlib"
sh /tools/34-make-zlib.sh > /logs/zlib 2>&1

echo "Make Bzip2"
sh /tools/35-make-bzip2.sh > /logs/bzip2 2>&1

echo "Make Xz Part 2"
sh /tools/36-make-xz.sh > /logs/xz-2 2>&1

echo "Make Zstd"
sh /tools/37-make-zstd.sh > /logs/zstd 2>&1

echo "Make File Part 2"
sh /tools/38-make-file.sh > /logs/file-2 2>&1

echo "Make Readline"
sh /tools/39-make-readline.sh > /logs/readline 2>&1

echo "Make M4 Part 2"
sh /tools/40-make-m4.sh > /logs/m4-2 2>&1

echo "Make BC"
sh /tools/41-make-bc.sh > /logs/bc 2>&1

echo "Make Flex"
sh /tools/42-make-flex.sh > /logs/flex 2>&1

echo "Make TCL"
sh /tools/43-make-tcl.sh > /logs/tcl 2>&1

echo "Make Expect"
sh /tools/44-make-expect.sh > /logs/expect 2>&1

echo "Make DejaGNU"
sh /tools/45-make-dejagnu.sh > /logs/dejagnu 2>&1

echo "Make Binutils Part 3"
sh /tools/46-make-binutils.sh > /logs/binutils-3 2>&1

echo "Make GMP"
sh /tools/47-make-gmp.sh > /logs/gmp 2>&1

echo "Make mpfr"
sh /tools/48-make-mpfr.sh > /logs/mpfr 2>&1

echo "Make mpc"
sh /tools/49-make-mpc.sh > /logs/mpc 2>&1

echo "Make Attr"
sh /tools/50-make-attr.sh > /logs/attr 2>&1

echo "Make ACL"
sh /tools/51-make-acl.sh > /logs/acl 2>&1

echo "Make Libcap"
sh /tools/52-make-libcap.sh > /logs/libcap 2>&1

echo "Make Cracklib"
sh /tools/53-make-cracklib.sh > /logs/cracklib 2>&1

echo "Make Shadow"
sh /tools/54-make-shadow.sh > /logs/shadow 2>&1

echo "Make GCC Part 3"
sh /tools/55-make-gcc.sh > /logs/gcc-3 2>&1

echo "Make Pck Config"
sh /tools/56-make-pkgconfig.sh > /logs/pkgconfig 2>&1

echo "Make Ncurses Part 2"
sh /tools/57-make-ncurses.sh > /logs/ncurses-2 2>&1

echo "Make Sed"
sh /tools/58-make-sed.sh > /logs/sed 2>&1

echo "Make Psmisc"
sh /tools/59-make-psmisc.sh > /logs/psmisc 2>&1

echo "Make Gettext Part 2"
sh /tools/60-make-gettext.sh > /logs/gettext-2 2>&1

echo "Make Bison Part 2"
sh /tools/61-make-bison.sh > /logs/bison-2 2>&1

echo "Make Grep"
sh /tools/62-make-grep.sh > /logs/grep 2>&1

echo "Make Bash Part 2"
sh /tools/63-make-bash.sh > /logs/bash-2 2>&1

echo "Make Libtool"
sh /tools/64-make-libtool.sh > /logs/libtool 2>&1

echo "Make GDBM"
sh /tools/65-make-gdbm.sh > /logs/gdbm 2>&1

echo "Make Gperf"
sh /tools/66-make-gperf.sh > /logs/gperf 2>&1

echo "Make Expat"
sh /tools/67-make-expat.sh > /logs/expat 2>&1

echo "Make Inetutils"
sh /tools/68-make-inetutils.sh > /logs/inetutils 2>&1

echo "Make Perl Part 2"
sh /tools/69-make-perl.sh > /logs/perl-2 2>&1

echo "Make XML Parser"
sh /tools/70-make-xml-parser.sh > /logs/xml-parser 2>&1

echo "Make Intltool"
sh /tools/71-make-intltool.sh > /logs/intltool 2>&1

echo "Make Autoconf"
sh /tools/72-make-autoconf.sh > /logs/autoconf 2>&1

echo "Make Automake"
sh /tools/73-make-automake.sh > /logs/automake 2>&1

echo "Make Kmod"
sh /tools/74-make-kmod.sh > /logs/kmod 2>&1

echo "Make Libelf"
sh /tools/75-make-libelf.sh > /logs/libelf 2>&1

echo "Make Libffi"
sh /tools/76-make-libffi.sh > /logs/libffi 2>&1

echo "Make OpenSLL"
sh /tools/77-make-opensll.sh > /logs/opensll 2>&1

echo "Make Python Part 2"
sh /tools/78-make-python.sh > /logs/python-2 2>&1

echo "Make Ninja"
sh /tools/79-make-ninja.sh > /logs/ninja 2>&1

echo "Make Meson"
sh /tools/80-make-meson.sh > /logs/meson 2>&1

echo "Make Coreutils Part 2"
sh /tools/81-make-coreutils.sh > /logs/coreutils-2 2>&1

echo "Make Check"
sh /tools/82-make-check.sh > /logs/check 2>&1

echo "Make Diffutils Part 2"
sh /tools/83-make-diffutils.sh > /logs/diffutils-2 2>&1

echo "Make Gawk Part 2"
sh /tools/84-make-gawk.sh > /logs/gawk 2>&1

echo "Make Findutils Part 2"
sh /tools/85-make-findutils.sh > /logs/findutils 2>&1

echo "Make Groff"
sh /tools/86-make-groff.sh > /logs/groff 2>&1

# Skip Grub since we will be using syslinux later on instead
#echo "Make Grub"
#sh /tools/87-make-grub.sh > /logs/grub 2>&1

echo "Make Less"
sh /tools/88-make-less.sh > /logs/less 2>&1

echo "Make Gzip"
sh /tools/89-make-gzip.sh > /logs/gzip 2>&1

echo "Make iproutes2"
sh /tools/90-make-iproutes2.sh > /logs/iproutes2 2>&1

echo "Make Kbd"
sh /tools/91-make-kbd.sh > /logs/kbd 2>&1

echo "Make Libpipeline"
sh /tools/92-make-libpipeline.sh > /logs/libpipeline 2>&1

echo "Make Make Part 2"
sh /tools/93-make-make.sh > /logs/make-2 2>&1

echo "Make Patch"
sh /tools/94-make-patch.sh > /logs/patch 2>&1

echo "Make Man DB"
sh /tools/95-make-mandb.sh > /logs/mandb 2>&1

echo "Make Tar Part 2"
sh /tools/96-make-tar.sh > /logs/tar-2 2>&1

echo "Make Texinfo Part 2"
sh /tools/97-make-texinfo.sh > /logs/texinfo 2>&1

echo "Make Nano"
sh /tools/98-make-nano.sh > /logs/nano 2>&1

echo "Make Eudev"
sh /tools/99-make-eudev.sh > /logs/eudev 2>&1

echo "Make Procps-ng"
sh /tools/100-make-procpsng.sh > /logs/procpsng 2>&1

echo "Make Util Linux"
sh /tools/101-make-util-linux.sh > /logs/util-linux 2>&1

echo "Make E2fsprogs"
sh /tools/102-make-e2fsprogs.sh > /logs/e2fsprogs 2>&1

echo "Make Sysklogd"
sh /tools/103-make-sysklogd.sh > /logs/sysklogd 2>&1

echo "Make Sysvinit"
sh /tools/104-make-sysvinit.sh > /logs/sysvinit 2>&1

if [ $LFS_STRIP -eq 1 ]; then
  echo "Clean Up Debugging Symbols Part 2"
  sh /tools/105-cleanup.sh > /logs/cleanup 2>&1
fi