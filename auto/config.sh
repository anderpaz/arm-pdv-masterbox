#!/bin/bash

set -e

if [ ! -d "build" ]; then
    echo "ERRO: diretório obrigatório não encontrado: $dir" >&2
    exit 1
fi

pushd build >/dev/null

lb config noauto \
    --binary-images iso-hybrid \
    --distribution bookworm \
    --parent-debian-installer-distribution bookworm \
    --architectures amd64 i386 \
    --linux-flavours amd64 \
    --mode debian \
    --debian-installer live \
    --initramfs live-boot \
    --system normal \
    --binary-file ext4 \
    --image-name aramo-pdv \
    --iso-application aramo \
    --iso-preparer Anderson \
    --iso-publisher andersonlix@gmail.com \
    --iso-volume aramo \
    --archive-areas "main contrib non-free non-free-firmware" \
    --debootstrap-options "--include=apt-transport-https,ca-certificates,openssl,e2fsprogs" \
    --bootappend-live "" \
    --memtest none \
    --source false \
    --apt-recommends false \
    --backports false \
    --updates false \
    --apt-indices false \
    "${@}"

popd >/dev/null