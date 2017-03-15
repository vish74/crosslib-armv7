FROM vish74/crosslib-base:latest

LABEL maintainer Vish "vishvesh@litmusloop.com"

RUN apt-get update && apt-get install -y \
  crossbuild-essential-armhf gcc-arm-linux-gnueabihf g++-arm-linux-gnueabihf  && \
  apt-get clean --yes

ENV GRPC_RELEASE_TAG v1.1.0

# Build grpc
RUN cd /home/grpc && \
    make clean && \
    make plugins

ENV GRPC_CROSS_COMPILE=true
ENV GRPC_CROSS_AROPTS="cr --target=elf32-little"

ENV CROSS_TRIPLE arm-linux-gnueabihf
ENV CROSS_ROOT /usr/bin
ENV AS=/usr/bin/${CROSS_TRIPLE}-as \
    AR=/usr/bin/${CROSS_TRIPLE}-ar \
    CC=/usr/bin/${CROSS_TRIPLE}-gcc \
    CPP=/usr/bin/${CROSS_TRIPLE}-cpp \
    CXX=/usr/bin/${CROSS_TRIPLE}-g++ \
    LDXX=/usr/bin/${CROSS_TRIPLE}-g++ \
    LD=/usr/bin/${CROSS_TRIPLE}-ld

RUN cd /home/grpc && \
    make HAS_PKG_CONFIG=false \
    CC=arm-linux-gnueabihf-gcc \
    CXX=arm-linux-gnueabihf-g++ \
    RANLIB=arm-linux-gnueabihf-ranlib \
    LD=arm-linux-gnueabihf-ld \
    LDXX=arm-linux-gnueabihf-g++ \
    AR=arm-linux-gnueabihf-ar \
    PROTOBUF_CONFIG_OPTS="--host=arm-linux-gnueabihf --with-protoc=/usr/local/bin/protoc" static

RUN git clone -b v1.2.8 https://github.com/madler/zlib /home/zlib/

RUN cd /home/zlib && ./configure && make