#!/bin/sh
# Usage: build_otp VERSION SOURCE_DIR TARGET_DIR OTP_TARGET OPENSSL_DIR XCOMP_CONF
set -euo pipefail
version=$1
source_dir=$2
target_dir=$3
otp_target=$4
openssl_dir=$5
xcomp_conf=$6

if [ ! -d $source_dir ]; then
  ref="OTP-$version"
  git clone --depth 1 https://github.com/erlang/otp --branch $ref $source_dir
fi

if [ ! -d $target_dir ]; then
  cd $source_dir
  export MAKEFLAGS="-j`nproc` -O"
  export ERL_TOP=`pwd`
  export ERLC_USE_SERVER=true
  export RELEASE_LIBBEAM=true
  ./otp_build configure \
    --enable-builtin-zlib \
    --xcomp-conf=$xcomp_conf \
    # --with-ssl=$openssl_dir \
    # --disable-dynamic-ssl-lib
  ./otp_build boot -s
  ./otp_build release -s $target_dir

  mkdir $target_dir/usr/lib
  libtool \
    -static \
    -o $target_dir/usr/lib/liberl.a \
    erts/emulator/ryu/obj/$otp_target/opt/libryu.a \
    erts/emulator/zlib/obj/$otp_target/opt/libz.a \
    erts/emulator/pcre/obj/$otp_target/opt/libepcre.a \
    erts/lib/internal/$otp_target/lib{erts_internal,ethread}.a \
    bin/$otp_target/libbeam.a
fi
