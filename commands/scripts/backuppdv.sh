#!/bin/bash

DIA=$(date +%d%m%Y)
DATA=$(date +%d%m%Y_%T)
path="/tmp/.backuppdv"
arqconf="/usr/aramo/pdv/pdv.conf"
m4="/usr/aramo/pdv"
user="root"
pass="123456"
banco="mvtopdv"

#####################################################################################################

iniciar()
{
    [[ ! -d ${path}/${DIA} ]] && mkdir -p ${path}/${DIA}
}

getcaminho()
{
    ARGS="$@"
    BARR=0
    for((i=0;i<${#ARGS};i++)); do
        ARR[$i]="${ARGS:i:1}"
        if [[ ${ARR[$i]} == "/" ]]; then
            BARR=$((BARR+1))
        fi
    done
    DIABKP=$(echo ${ARGS} | cut -d "/" -f $((BARR+1)) | cut -d "." -f 1 | cut -d "_" -f 4)
    CARQ=$(echo ${ARGS} | cut -d "/" -f $((BARR+1)))
}

getserv()
{
    servidor=$(cat ${arqconf}  | grep -i ipservidor | cut -d "=" -f 2 | awk '{print $1}')
    ping -c 2 -w 4 $servidor >/dev/null 2>&1
    if [[ ! $? -eq 0 ]]; then
        yad --center --height=190 --width=240 --undecorated  --text "\n<b><big> Atencao!!!</big></b>\n\t<big>Servidor Invalido ou Inacessivel.</big>" --button="Fechar!window-close:1" --image="dialog-warning"
        echo "Erro em Conectar com o servidor"
        echo
        echo " --> ESC PARA CONTINUAR. <--"
        exit 1
    fi
}

mysqlbkp()
{
    mysqldump -u$user -p$pass $banco > $path/${DIA}/mvtopdv_${DATA}.sql
    if [[  $? -ne 0 ]]; then
        yad --center --height=190 --width=240 --undecorated  --text "\n<b><big> Atencao!!!</big></b>\n\t<big>Falha ao realizar backup do pdv.</big>" --button="Fechar!window-close:1" --image="dialog-warning"
        echo "Erro em Fazer o Backup do Mysql"
        echo
        echo " --> ESC PARA CONTINUAR. <--"
        exit 1
    fi
}

envbkp()
{
    pushd $path > /dev/null
        ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@$servidor echo >/dev/null 2>&1
        if [[ $? -eq 0 ]]; then
            loja=$(cat ${arqconf}  | grep -i empresa | cut -d "=" -f 2 | awk '{print $1}')
            pdv=$(cat ${arqconf}  | grep -i pdv | cut -d "=" -f 2 | awk '{print $1}')
            SBKP="/banco/bkp/${loja}/${pdv}"
            cp ${m4}/pdv $path/${DIA}/
            cp ${m4}/pdv.conf $path/${DIA}/
            cp ${m4}/*.${pdv} $path/${DIA}/
            cp ${m4}/*.ini $path/${DIA}/
            tar czf pdv_${pdv}_${loja}_${DIA}.tar.gz ${DIA} >/dev/null 2>&1
            rm -rf ${DIA}
            ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@$servidor "[[ ! -e ${SBKP} ]] && { mkdir -p ${SBKP} ; }" >/dev/null 2>&1
            scp -o ConnectTimeout=5 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null *.gz root@${servidor}:${SBKP} >/dev/null 2>&1
            ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@$servidor "find ${SBKP} -type f -atime +30 -exec /bin/rm -f {} \;" >/dev/null 2>&1
            for i in $(ls *gz); do
                mv ${i} ${i}.OK
            done
        else
            loja=$(cat ${arqconf}  | grep -i empresa | cut -d "=" -f 2 | awk '{print $1}')
            pdv=$(cat ${arqconf}  | grep -i pdv | cut -d "=" -f 2 | awk '{print $1}')
            SBKP="/banco/bkp/${loja}/${pdv}"
            cp ${m4}/pdv $path/${DIA}/
            cp ${m4}/pdv.conf $path/${DIA}/
            cp ${m4}/*.${pdv} $path/${DIA}/
            cp ${m4}/*.ini $path/${DIA}/
            tar czf pdv_${pdv}_${loja}_${DIA}.tar.gz ${DIA} >/dev/null 2>&1
            rm -rf ${DIA}
            yad --center --height=120 --width=340 --undecorated  --text "\n<b><big> Atencao!!!\n</big></b>\n\nNão foi Possivel Acessar o Servidor\nEntrar em contato com suporte." --button="Fechar!window-close:1" --image="dialog-warning"
        fi
    popd > /dev/null
}

getbkp()
{
    pushd $path > /dev/null
        ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@$servidor echo >/dev/null 2>&1
        if [[ $? -eq 0 ]]; then
            loja=$(cat ${arqconf}  | grep -i empresa | cut -d "=" -f 2 | awk '{print $1}')
            pdv=$(cat ${arqconf}  | grep -i pdv | cut -d "=" -f 2 | awk '{print $1}')
            SBKP="/banco/bkp/${loja}/${pdv}"
            ARQ=$(ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@$servidor "ls -lhtraF ${SBKP}/* | tail -1")
            if [[ -n ${ARQ} ]]; then
                ARQ=$(echo ${ARQ} | awk '{print $9}' | cut -d "/" -f 6)
                yad --center --undecorated --borders=15 --width="400" --height="100" --button="Nao!window-close:1" --button="gtk-ok:0" --text="\n\t<b><big> Atencao!!!\n</big></b>\n\nLocalizado o arquivo\n<b>${ARQ}</b>\nPara restauracao.\n\nConfirma?"  --image=document-save
                if [[ $? -ne 0 ]]; then
                    ARQ=$(yad --form --center --undecorated --borders=15 --width="400" --height="100" --button="Cancela!window-close:1" --button="gtk-ok:0" --text="\n\t<b><big>Digite o nome do arquivo a ser Recuperado</big></b>\n\n"  --field='Arquivo' '' --image=document-save)
                    if [[ $? -ne 0 ]]; then
                        echo "Erro em Restaurar o Backup"
                        echo
                        echo " --> ESC PARA CONTINUAR. <--"
                        exit 1
                    fi
                    ARQ=$(echo ${ARQ} | cut -d "|" -f 1)
                    DIABKP=$(echo ${ARQ} | cut -d "." -f 1 | cut -d "_" -f 4)
                    scp -o ConnectTimeout=5 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@${servidor}:${SBKP}/${ARQ} . >/dev/null 2>&1
                    if [[ -e ${ARQ} ]]; then
                        tar xf ${ARQ}
                        mv ${DIABKP}/pdv ${m4}/
                        mv ${DIABKP}/pdv.conf ${m4}/
                        mv ${DIABKP}/*.${pdv} ${m4}/
                        mv ${DIABKP}/*.ini ${m4}/
                        mysql -uroot -p123456 -e "drop database mvtopdv;" -f
                        mysql -uroot -p123456 -e "create database mvtopdv;" -f
                        mysql -uroot -p123456 mvtopdv < ${DIABKP}/mvtopdv_${DIABKP}*.sql
                    else
                        yad --center --height=120 --width=340 --undecorated  --text "\n<b><big> Atencao!!!\n</big></b>\n\nNão Encontrado arquivo de Backup no Servidor" --button="Fechar!window-close:1" --image="dialog-warning"
                        echo "Erro em Restaurar o Backup"
                        echo
                        echo " --> ESC PARA CONTINUAR. <--"
                        exit 1
                    fi
                fi
            else
                yad --center --height=120 --width=340 --undecorated  --text "\n<b><big> Atencao!!!\n</big></b>\n\nNão Encontrado arquivo de Backup no Servidor" --button="Fechar!window-close:1" --image="dialog-warning"
                ARQ=$(yad --form --center --undecorated --borders=15 --width="400" --height="100" --button="gtk-ok:0" --button="Cancela!window-close:1" --text="\n\t<b><big>Digite o Caminho e o Nome do Arquivo a ser Recuperado do Servidor</big></b>\n\n"  --field='Arquivo' '' --image=document-save)
                if [[ $? -eq 0 ]]; then
                    ARQ=$(echo ${ARQ} | cut -d "|" -f 1)
                    getcaminho ${ARQ}
                    scp -o ConnectTimeout=5 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@${servidor}:${ARQ} . >/dev/null 2>&1
                    if [[ -e ${CARQ} ]]; then
                        tar xf ${CARQ}
                        mv ${DIABKP}/pdv ${m4}/
                        mv ${DIABKP}/pdv.conf ${m4}/
                        mv ${DIABKP}/*.${pdv} ${m4}/
                        mv ${DIABKP}/*.ini ${m4}/
                        mysql -uroot -p123456 -e "drop database mvtopdv;" -f
                        mysql -uroot -p123456 -e "create database mvtopdv;" -f
                        mysql -uroot -p123456 mvtopdv < ${DIABKP}/mvtopdv_${DIABKP}*.sql
                    else
                        yad --center --height=120 --width=340 --undecorated  --text "\n<b><big> Atencao!!!\n</big></b>\n\nNão Encontrado arquivo de Backup no Servidor" --button="Fechar!window-close:1" --image="dialog-warning"
                        echo "Erro em Restaurar o Backup"
                        echo
                        echo " --> ESC PARA CONTINUAR. <--"
                        exit 1
                    fi
                else
                    echo "Erro em Restaurar o Backup"
                    echo
                    echo " --> ESC PARA CONTINUAR. <--"
                    exit 1
                fi
            fi
        else
            yad --center --height=120 --width=340 --undecorated  --text "\n<b><big> Atencao!!!\n</big></b>\n\nNão foi Possivel Acessar o Servidor\nEntrar em contato com suporte." --button="Fechar!window-close:1" --image="dialog-warning"
        fi
    popd > /dev/null
}

rbackuppdv()
{
    echo
    echo "Iniciando processo de restauração."
    echo
    echo "Criando pastas."
    iniciar
    echo "OK!"
    echo
    echo "Obtendo arquivo de configuração."
    getserv
    echo "OK!"
    echo
    echo "Obtendo backup."
    getbkp
    echo "OK!"
    echo
    echo " --> RESTAURACAO REALIZADA COM SUCESSO. <--"
    echo
    echo " --> ESC PARA CONTINUAR. <--"
}

rbackupconfirma()
{
    yad --center --undecorated --borders=15 --button="Não!gtk-cancel:1" --button="Sim!gtk-ok:0" --text="\n\t<b><big>RESTAURAR BACKUP DO PDV</big></b>\n\nDeseja <b>RESTAURAR</b> do pdv?" --image=document-save --width=400
    if [[ $? -eq 0 ]]; then
        rbackuppdv | yad --text-info --tail --text="\n\t\t<b><big>RECUPERAR BACKUP DO PDV</big></b>" --width="400" --height="350" --center --no-buttons --auto-close --auto-kill
    fi
}

cmanualbkpdia()
{
    echo
    echo " --> INICIANDO PROCESSO DE BACKUP. <--"
    echo "Criando pastas."
    iniciar
    echo "OK!"
    echo
    echo "Obtendo arquivo de configuração."
    getserv
    echo "OK!"
    echo
    echo "Fazendo backup do banco de dados."
    mysqlbkp
    echo "OK!"
    echo
    echo "Compactando e enviando backup para o servidor."
    envbkp
    echo "OK!"
    echo
    echo " --> BACKUP MANUAL REALIZADO COM SUCESSO. <--"
    echo
    shutdown -r now
}

cmanualbkp()
{
    echo
    echo " --> INICIANDO PROCESSO DE BACKUP. <--"
    echo "Criando pastas."
    iniciar
    echo "OK!"
    echo
    echo "Obtendo arquivo de configuração."
    getserv
    echo "OK!"
    echo
    echo "Fazendo backup do banco de dados."
    mysqlbkp
    echo "OK!"
    echo
    echo "Compactando e enviando backup para o servidor."
    envbkp
    echo "OK!"
    echo
    echo " --> BACKUP MANUAL REALIZADO COM SUCESSO. <--"
    echo
    echo " --> ESC PARA CONTINUAR. <--"
}

cmanualbkpconfirma()
{
    yad --center --undecorated --borders=15 --button="Não!gtk-cancel:1" --button="Sim!gtk-ok:0" --text="\n\t<b><big>BACKUP MANUAL DO PDV</big></b>\n\nDeseja realmente fazer o <b>BACKUP</b> do pdv?" --image=document-save --width=400
    if [[ $? -eq 0 ]]; then
        cmanualbkp | yad --text-info --tail --text="\n\t\t<b><big>BACKUP DO PDV</big></b>" --width="400" --height="350" --center --no-buttons --auto-close --auto-kill
    fi

}

autobkp()
{
    echo
    echo " --> INICIANDO PROCESSO DE BACKUP. <--"
    echo " --> NAO DESLIGUE O PDV. <--"
    echo
    echo "Criando pastas."
    iniciar
    echo "OK!"
    echo
    echo "Obtendo arquivo de configuração."
    getserv
    echo "OK!"
    echo
    echo "Fazendo backup do banco de dados."
    mysqlbkp
    echo "OK!"
    echo
    echo "Compactando e enviando backup para o servidor."
    envbkp
    echo "OK!"
    echo
    echo " --> BACKUP MANUAL REALIZADO COM SUCESSO. <--"
    echo " --> DESLIGANDO PDV. <--"
    shutdown -h now
}

mnbackuppdv() {

    while :; do
        OPCAO7=$(yad --image=${LOGO} --image-on-top \
					--list --undecorated \
					--width=520 --height=290 --center \
					--column='':NUM --column='                          Selecione uma das opcoes':TEXT \
					--search-column=1 --no-buttons --borders=5 --no-escape \
					--window-icon="" --no-headerss --print-column=1 --separator='' --hide-column=0 \
                1 '<big>Backup manual do PDV</big>' \
                2 '<big>Restaurar backup no PDV</big>' \
                3 '<big>Voltar</big>')
        [[ $? -ne 0 ]] && break
        case "$OPCAO7" in
            1)
                cmanualbkpconfirma
                ;;
            2)
                rbackupconfirma
                ;;
            3)
                break
                ;;
        esac
    done

}

#####################################################################################################

case $1 in

    autobkp)
        autobkp | yad --text-info --tail --text="\n\t\t<b><big>BACKUP DO PDV</big></b>" --width="400" --height="350" --center --no-buttons --auto-close --auto-kill
        ;;
    mnbackuppdv)
        numlockx on
        mnbackuppdv
        ;;
    cmanualbkpdia)
        cmanualbkpdia
        ;;
esac
