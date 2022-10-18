#!/bin/sh
# Usage: build_otp VERSION SOURCE_DIR TARGET_DIR OTP_TARGET SSL_DIR XCOMP_CONF STATIC_NIFS
set -euo pipefail
url=$1
ref=$2
source_dir=$3
target_dir=$4
otp_target=$5
ssl_dir=$6
xcomp_conf=$7
static_nifs=$8

if [ ! -d $source_dir ]; then
  git clone --depth 1 $url --branch $ref $source_dir
fi

pwd=$PWD
cd $source_dir
export MAKEFLAGS="-j`nproc`"
export ERL_TOP=`pwd`
export ERLC_USE_SERVER=true
export RELEASE_LIBBEAM=true
export LIBS=$ssl_dir/lib/libcrypto.a

if [ ! -d $target_dir ]; then
  ./otp_build configure \
    --without-{common_test,debugger,dialyzer,diameter,edoc,eldap,erl_docgen,et,eunit,ftp,inets,jinterface,megaco,mnesia,observer,odbc,os_man,tftp,wx,xmerl} \
    --xcomp-conf=$xcomp_conf \
    --enable-builtin-zlib \
    --with-ssl=$ssl_dir \
    --disable-dynamic-ssl-lib \
    --enable-static-nifs=$static_nifs,$PWD/lib/crypto/priv/lib/$otp_target/crypto.a
  ./otp_build boot -a
  ./otp_build release -a $target_dir
fi

mkdir -p $target_dir/usr/lib
libtool \
  -static \
  -o $target_dir/usr/lib/liberl.a \
  erts/emulator/ryu/obj/$otp_target/opt/libryu.a \
  erts/emulator/zlib/obj/$otp_target/opt/libz.a \
  erts/emulator/pcre/obj/$otp_target/opt/libepcre.a \
  erts/lib/internal/$otp_target/lib{erts_internal,ethread}.a \
  bin/$otp_target/libbeam.a \
  $static_nifs \
  $ssl_dir/lib/libcrypto.a \
  $PWD/lib/asn1/priv/lib/$otp_target/asn1rt_nif.a \
  $PWD/lib/crypto/priv/lib/$otp_target/crypto.a
