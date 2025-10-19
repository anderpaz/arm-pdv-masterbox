#!/bin/bash

CONF="/usr/aramo/pdv/pdv.conf"

addchave()
{
	SERVER=$(cat $CONF | grep -Ei "ipservidor" | cut -d "=" -f 2 | awk '{print $1}')
    PIDYAD=$(ps -auxf | grep yad | grep -v mnpdv | grep -v grep | grep tail | awk '{print $2}')
	echo 
	echo "Aguarde verificando conexao com o servidor"
	sleep 3
    ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${USUARIO}@${SERVER} echo >/dev/null 2>&1
    if [[ $? -eq 0 ]];then
        echo 
        echo"Servidor ja Contem a Chave desse pdv."
    else
        US=$(yad --form --center --undecorated --borders=15 --width="400" --height="100" --button="gtk-ok:0" --button="Cancela!window-close:1" --text="\n\t<b><big>Digite o usuario e a senha de  acesso ao servidor</big></b>\n\n"  --field='Usuario' '' --field='Senha' '' --image='auth-fingerprint-symbolic')
        if [[ -z $US ]]; then
            yad --center --height=90 --width=240 --undecorated  --text "\n<b><big> Atencao!!!\n</big></b>\n\nNão Encontrado Arquivo de Confiugração" --button="Fechar!window-close:1" --image="dialog-warning"
            kill -9 ${PIDYAD}
            exit 1
        fi
        USUARIO=$(echo ${US} | cut -d "|" -f 1)
        PASS=$(echo ${US} | cut -d "|" -f 2)
        sshpass -p "${PASS}" ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${USUARIO}@${SERVER} echo >/dev/null 2>&1
        if [[ $? -eq 0 ]]; then
            if [[ ! -e /root/.ssh/id_rsa ]];then
                ssh-keygen -N "" -f /root/.ssh/id_rsa -t rsa -b 4096
                sshpass -p "${PASS}" ssh-copy-id -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i /root/.ssh/id_rsa.pub ${USUARIO}@${SERVER}
            else
                sshpass -p "${PASS}" ssh-copy-id -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i /root/.ssh/id_rsa.pub ${USUARIO}@${SERVER}
            fi
        else
            yad --center --height=110 --width=340 --undecorated  --text "\n<b><big> Atencao!!!\n</big></b>\n\nNão foi Possivel Acessar o Servidor\nUsuario ou Senha Invalidos" --button="Fechar!window-close:1" --image="dialog-warning"
            kill -9 ${PIDYAD}
            exit 1
        fi
    fi
    echo 
    echo
    echo  "-------> Tecla ESC para continuar <-------"
}

[[ ! -e $CONF ]] && { yad --center --height=90 --width=240 --undecorated  --text "\n<b><big> Atencao!!!\n</big></b>\n\nNão Encontrado Arquivo de Confiugração" --button="Fechar!window-close:1" --image="dialog-warning" ; exit 1 ; }

addchave | yad --text-info --tail --undecorated --borders=15 --width="400" --height="350" --center --no-buttons --auto-close --auto-kill --image="network-wired-disconnected" --image-on-top --text="\t\t<b><big>BACKUP PDV</big></b>\n"