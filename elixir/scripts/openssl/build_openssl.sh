#!/bin/sh
# Usage: build_openssl URL VERSION SOURCE_DIR TARGET_DIR TARGET
set -euo pipefail
export MAKEFLAGS=-j`nproc`
url=$1
ref=$2
source_dir=$3
target_dir=$4
target=$5

if [ ! -d $source_dir ]; then
  git clone --depth 1 $url --branch $ref $source_dir
fi

cp scripts/openssl/15-ios.conf $source_dir/Configurations/15-ios.conf

if [ ! -d $target_dir ]; then
  cd $source_dir
  ./Configure $target --prefix=$target_dir
  make clean
  make
  make install_sw
fi
