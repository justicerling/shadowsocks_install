#!/bin/sh
#
# This is a Shell script for build multi-architectures v2ray-plugin binary file
# 
# Supported architectures: amd64, arm32v6, arm32v7, arm64v8, i386, ppc64le, s390x
# 
# Copyright (C) 2020 Teddysun <i@teddysun.com>
#
# Reference URL:
# https://github.com/shadowsocks/v2ray-plugin

cur_dir="$(pwd)"

COMMANDS=( git go )
for CMD in "${COMMANDS[@]}"; do
    if [ ! "$(command -v "${CMD}")" ]; then
        echo "${CMD} is not installed, please install it and try again" && exit 1
    fi
done

cd ${cur_dir}
git clone https://github.com/shadowsocks/v2ray-plugin.git
cd v2ray-plugin || exit 2

VERSION="$(git describe --tags)"
LDFLAGS="-X main.VERSION=$VERSION -s -w"
GCFLAGS=""
ARCHS=( 386 amd64 arm arm64 ppc64le s390x )
ARMS=( 6 7 )

for ARCH in ${ARCHS[@]}; do
    if [ "${ARCH}" = "arm" ]; then
        for V in ${ARMS[@]}; do
            echo "Building v2ray-plugin_linux_${ARCH}${V}"
            env CGO_ENABLED=0 GOOS=linux GOARCH=${ARCH} GOARM=${V} go build -v -ldflags "${LDFLAGS}" -gcflags "${GCFLAGS}" -o ${cur_dir}/v2ray-plugin_linux_${ARCH}${V}
        done
    else
        echo "Building v2ray-plugin_linux_${ARCH}"
        env CGO_ENABLED=0 GOOS=linux GOARCH=${ARCH} go build -v -ldflags "${LDFLAGS}" -gcflags "${GCFLAGS}" -o ${cur_dir}/v2ray-plugin_linux_${ARCH}
    fi
    echo "Build v2ray-plugin_linux_${ARCH} completed"
done

# clean up
cd ${cur_dir} && rm -fr v2ray-plugin
