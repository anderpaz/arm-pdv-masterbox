#!/bin/bash

arq=$(setserial -g /dev/ttyS* | cut -d "/" -f 3-10 | grep -v 'unknown')

if [[ -z ${arq} ]]; then
    yad --center --height=10 --width=410 --undecorated --text "\n<b><big>\t\tPortas Seriais</big></b>\n\n<b><big> Portas localizadas:</big></b>:\n\nNão Encontrada Porta Serial Disponivel." --button="Fechar!window-close:1" --image="dialog-warning"
else
    yad --center --height=10 --width=410 --undecorated --text "\n<b><big>\t\tPortas Seriais</big></b>\n\n<b><big> Portas localizadas:</big></b>:\n\n${arq}" --button="Fechar!window-close:1" --image="dialog-warning"
fi