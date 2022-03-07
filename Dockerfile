FROM ubuntu:21.04

LABEL maintainer="James Holmes"
LABEL maintainer_email="jjholmes@ucsd.edu"
LABEL version="1.0"

# Set versions of SIOSEIS and SU
ARG SIOSEIS_VER=sioseis-2021.1.2
ARG SU_VER=cwp_su_all_44R23
ARG PATCH_FILE1=convert-fix.sio_msp.patch
ARG PATCH_FILE2=$SU_VER.sio_msp.patch

# Setup the paths, install necessary dependencies, and remove extraneous stuff
ENV PATH="/app/sioseis/bin:/app/su/bin:/seisproc:${PATH}"
ENV CWPROOT="/app/su"

RUN set -ex && mkdir /app /app/sioseis /app/sioseis/bin /app/su 

ADD https://drive.google.com/uc?export=download&id=1GjwNoKkncm8pywtqsGAyIEPeWkDOpjGm /app/$PATCH_FILE1

RUN set -ex && \
    apt-get update && \ 
    apt-get --no-install-recommends install -y make gcc gfortran patch bzip2 libx11-dev libxt-dev imagemagick xli ghostscript && \
    rm -f /usr/lib/gcc/x86_64-linux-gnu/10/lto1 && \
    rm -f /usr/lib/gcc/x86_64-linux-gnu/10/lto-wrapper && \
    patch -u /etc/ImageMagick-6/policy.xml < /app/$PATCH_FILE1 && \
    rm -f /app/$PATCH_FILE1

# Unzip and make SIOSEIS
ADD https://sioseis.ucsd.edu/src/$SIOSEIS_VER.tar.bz2 /app/sioseis/$SIOSEIS_VER.tar.bz2
RUN set -ex && \
    cd /app/sioseis && \
    tar jxf $SIOSEIS_VER.tar.bz2 && \
    cd $SIOSEIS_VER && \
    make lsd && \
    make lsh && \
    make sioseis && \
    mv -t /app/sioseis/bin sioseis lsd lsh && \
    cd .. && \
    rm -rf $SIOSEIS_VER $SIOSEIS_VER.tar.bz2

# Unzip and make SU
ADD https://drive.google.com/uc?export=download&id=13Ym9NIgtnTE30FN7Can1700SC2vmjYZ7 /app/su/$PATCH_FILE2
ADD https://drive.google.com/uc?export=download&id=18-Mr1mFVBV1GHJz1O6Z1nXZgC7afKflW /app/su/Makefile.config
ADD https://nextcloud.seismic-unix.org/s/LZpzc8jMzbWG9BZ/download?path=%2F&files=$SU_VER.tgz /app/su/$SU_VER.tgz
RUN set -ex && \
	cd /app/su && \
	tar zxf $SU_VER.tgz && \
	patch -u -d src < $PATCH_FILE2 && \
	cp Makefile.config src && \
	cd src && \
	make install && \
	make xtinstall && \
    cd /app/su && \
    rm -rf $PATCH_FILE2 $SU_VER.tgz Makefile.config src
    
# Post-installation steps
RUN set -ex && \
	apt-get remove -y gcc gfortran patch make && \
	apt autoremove -y && \
	apt-get --no-install-recommends install -y libgfortran5 csh  && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /seisproc
COPY scripts/* /seisproc
RUN chmod +x /seisproc/*
WORKDIR /seisproc/data

    
CMD ["/bin/bash"]
