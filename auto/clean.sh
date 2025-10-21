#!/bin/bash

set -e

if [ ! -d "build" ]; then
    echo "ERRO: diretório obrigatório não encontrado: $dir" >&2
    exit 1
fi

pushd build >/dev/null

sudo lb clean noauto "$@"

for arg in "$@"; do
    if [ "$arg" = "--purge" ]; then
        rm .build/ config/ build.log sources.list cache/ -Rf
    fi
done

popd >/dev/null