#!/bin/bash

set -e

if [ ! -d "build" ]; then
    echo "ERRO: diretório obrigatório não encontrado: $dir" >&2
    exit 1
fi

pushd build >/dev/null

#sed -i '/^#/d' config/includes.installer/preseed.cfg
#sed -i '/^$/d' config/includes.installer/preseed.cfg

lb build noauto "${@}" 2>&1 | tee ../build.log

popd >/dev/null