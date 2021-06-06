FROM debian:buster

# Install required libs
RUN apt-get update      &&      \
    apt-get upgrade -y  &&      \
    apt-get install -y          \
    build-essential             \
    bison                       \
    gawk                        \
    make                        \
    python3                     \
    texinfo                     \
    bc                          \
    genisoimage                 \
    sudo

# Create a symbolic link to bash
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# LFS mount point
ENV LFS=/mnt/lfs

# Location of initrd tree
ENV INITRD_TREE=/mnt/lfs

# Loop device, using No.2 as docker for windows use loop0 & loop1..for something
ENV LOOP=/dev/loop2

# INITRD size, must be in sync with kernel config CONFIG_BLK_DEV_RAM_SIZE
ENV IMAGE_SIZE=2000000

# Output image
ENV IMAGE=isolinux/ramdisk.img

# Make flags, note that some make jobs are hardcoded to -j1
ENV MAKEFLAGS "-j4"

# Additional runtime variables
# Testing and backup defaults are defined here
# By default always run tests & perform sectioned backups
# All outputs will be located in the $LFS/outputs folder

# Install docs when they are avaiable
ENV LFS_DOCS = 1
# Perform all make tests & checks
ENV LFS_TEST = 1
# Perform a backup after cross toolchain stage has been completed (stripped symbols)
ENV XTOOLCHAIN_BACKUP = 1
# Perform a backup after system build & configuration
ENV LFS_BACKUP = 1

# Create required working dirs
RUN mkdir -pv $LFS/sources && chmod -v a+wt $LFS/sources
RUN mkdir -pv $LFS/tools

COPY libs/ $LFS/sources/
COPY [  "scripts/build.sh",             \
        "scripts/kernel.config",        \
        "scripts/createDisk.sh",        \
        "scripts/versionVerify.sh",     \
        "scripts/chrootCommands.sh",    \
        "scripts/chrootCommands-2.sh",  \
        "scripts/chrootCommands-3.sh",  \
        "scripts/init.sh",              \
        "/$LFS/tools/"                  ]

# Create the lfs user
RUN groupadd lfs && useradd -s /bin/bash -g lfs -m -k /dev/null lfs && echo "lfs:lfs" | chpasswd

RUN mkdir -pv $LFS/{bin,etc,lib,sbin,usr,var,logs,output} && case $(uname -m) in  x86_64) mkdir -pv $LFS/lib64 ;;esac
RUN chown -v lfs $LFS/{usr,lib,var,etc,bin,sbin,tools,logs,output,sources} && case $(uname -m) in  x86_64) chown -v lfs $LFS/lib64 ;;esac

# Avoid sudo password and keep variables
RUN echo "lfs ALL = NOPASSWD : ALL" >> /etc/sudoers
RUN echo 'Defaults env_keep += "LFS LFS_TGT MAKEFLAGS LFS_TEST LFS_DOCS XTOOLCHAIN_BACKUP LFS_BACKUP LOOP IMAGE_SIZE INITRD_TREE IMAGE"' >> /etc/sudoers


WORKDIR $LFS/sources

RUN [[ ! -e /etc/bash.bashrc ]] || mv -v /etc/bash.bashrc /etc/bash.bashrc.NOUSE

USER lfs
COPY [  "config/.bash_profile", \
        "config/.bashrc",       \
        "/home/lfs/"            ]
RUN source ~/.bash_profile

ENTRYPOINT ["bash", "-c", "$LFS/scripts/init.sh"]