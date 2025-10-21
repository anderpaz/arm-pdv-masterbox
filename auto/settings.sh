#!/bin/bash

set -e

if [ ! -d "build" ]; then
    echo "ERRO: diretório obrigatório não encontrado: $dir" >&2
    exit 1
fi

pushd build >/dev/null

chmod +x config/* -Rf
rsync -a --relative config/* build

>build/config/package-lists/live.list.chroot
sed -i 's/^LB_BOOTAPPEND_LIVE=.*$/LB_BOOTAPPEND_LIVE=""/' ../build/config/binary
sed -i 's/^LB_BOOTAPPEND_LIVE_FAILSAFE=.*$/LB_BOOTAPPEND_LIVE_FAILSAFE=""/' ../build/config/binary
sed -i 's/^LB_FIRMWARE_CHROOT=.*$/LB_FIRMWARE_CHROOT="false"/' ../build/config/binary

echo "Processo concluído."

popd >/dev/null