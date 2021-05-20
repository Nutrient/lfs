FROM debian

# Install required libs
RUN apt-get update && \
    apt-get install  -y \
    build-essential\
    bison\
    gawk \
    make \
    python3 \
    texinfo \
    sudo

# Create a symbolic link to bash
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# LFS mount point
ENV LFS=/mnt/lfs

# location of initrd tree
ENV INITRD_TREE=/mnt/lfs

# loop device, using No.2 as docker for windows use loop0 & loop1..for something
ENV LOOP=/dev/loop2
# In KBs (10GB)
#ENV IMAGE_SIZE=10000000
# 1GB for testing
ENV IMAGE_SIZE=1000000


# output image
ENV IMAGE=ramdisk.img

ENV MAKEFLAGS "-j4"

# Create required working dirs
RUN mkdir -pv $LFS/sources && chmod -v a+wt $LFS/sources
RUN mkdir -pv $LFS/tools

COPY libs/ $LFS/sources/
COPY [  "scripts/",    \
        "/$LFS/tools"  ]



# Create the lfs user
RUN groupadd lfs && useradd -s /bin/bash -g lfs -m -k /dev/null lfs && echo "lfs:lfs" | chpasswd


RUN mkdir -pv $LFS/{bin,etc,lib,sbin,usr,var,logs,output} && case $(uname -m) in  x86_64) mkdir -pv $LFS/lib64 ;;esac
RUN chown -v lfs $LFS/{usr,lib,var,etc,bin,sbin,tools,logs,output,sources} && case $(uname -m) in  x86_64) chown -v lfs $LFS/lib64 ;;esac

# avoid sudo password
RUN echo "lfs ALL = NOPASSWD : ALL" >> /etc/sudoers
RUN echo 'Defaults env_keep += "LFS LC_ALL LFS_TGT PATH MAKEFLAGS FETCH_TOOLCHAIN_MODE LFS_TEST LFS_DOCS JOB_COUNT LOOP IMAGE_SIZE INITRD_TREE IMAGE"' >> /etc/sudoers


WORKDIR $LFS/sources

RUN [[ ! -e /etc/bash.bashrc ]] || mv -v /etc/bash.bashrc /etc/bash.bashrc.NOUSE


COPY [  "config/.bash_profile", \
        "config/.bashrc",       \
        "/home/lfs/"            ]

USER lfs

#ENTRYPOINT ["bash", "./scripts/init.sh"]