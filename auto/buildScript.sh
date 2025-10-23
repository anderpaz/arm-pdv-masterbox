#!/bin/bash

set -e

SCRIPT_DIR="commands"
BIN_DIR="../config/includes.chroot_after_packages/usr/local/bin"

if [ ! -d "$SCRIPT_DIR" ]; then
    echo "ERRO: diretório obrigatório não encontrado: $dir" >&2
    exit 1
fi

pushd "$SCRIPT_DIR" >/dev/null

mkdir -p "$BIN_DIR"

for script in *.sh; do
  filename=$(basename "$script" .sh)
  echo "Criptografando $script"
  shc -r -U -m "Att. andersonlix@gmail.com.br" -f "$script" -o "${filename}"
  rm -f "${script}.x.c"
  mv "${filename}" "${BIN_DIR}/${filename}" -f
done

echo "Processo concluído."

popd >/dev/null