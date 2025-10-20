#!/bin/bash

arqshut="/root/.cxoffice/Aramo/drive_c/windows/system32/shutdown.exe"
arqbkp="/root/.cxoffice/Aramo/drive_c/windows/backuppdv.conf"
arqchave="$path/chave"
path="/tmp/.backuppdv"
banco="masterbox"
masterbox="/mnt/Aramo/MASTERBOX/"
regedit="/root/.cxoffice/Aramo/system.reg"
user="root"
pass="152100"
servicemdb="/etc/init.d/mysql"
arqcriamdb="/tmp/criamdb"
confmdb="/etc/mysql/mariadb.conf.d/50-server.cnf"
pathbkp="/banco/backupAramo"

#####################################################################################################

mnbackuppdv() {

    while :; do
        OPCAO7=$(
            yad --list \
                --title="BACKUP PDV" --text='Tecle ESC para voltar.' \
                --width=280 --height=320 --center \
                --column='OPCAO7':NUM --column='texto':TEXT \
                --window-icon="" --no-headers --print-column=1 --separator='' --hide-column=1 \
                700 '<big>Backup manual do PDV</big>' \
                701 '<big>Restaurar backup no PDV</big>' \
                702 '<big>Configuração do backup</big>' \
                703 '<big>Reconfigurar backup diario</big>'
        )
        [ $? -ne 0 ] && break
        case "$OPCAO7" in
        700)
            cmanualbkpconfirma
            ;;
        701)
            rbackupconfirma
            ;;
        702)
            editarbkp
            ;;
        703)
            bkpdiario
            ;;
        esac
    done

}

depSsh() {

    chave=''
    echo '' >$arqchave >/dev/null 2>&1
    if [ -z $chave ]; then
        echo -n 'ssh =+ 1 : ' >/dev/null 2>&1
        sshpass -p "$senhaserv" ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $servidor echo >/dev/null 2>&1
        if [ $? -eq 0 ]; then
            chave="ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
            echo -n 'Ok' >/dev/null 2>&1
        fi
    fi
    if [ -z $chave ]; then
        echo -n 'ssh =+ 2 : ' >/dev/null 2>&1
        sshpass -p "$senhaserv" ssh -o ConnectTimeout=5 -o HostKeyAlgorithms=+ssh-dss -o StrictHostKeyChecking=no $servidor echo >/dev/null 2>&1
        if [ $? -eq 0 ]; then
            chave="ssh -o HostKeyAlgorithms=+ssh-dss"
            echo -n 'Ok' >/dev/null 2>&1
        fi
    fi
    if [ -z $chave ]; then
        echo -n 'ssh =+ 3 : ' >/dev/null 2>&1
        sshpass -p "$senhaserv" ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o HostKeyAlgorithms=+ssh-dss $servidor echo >/dev/null 2>&1
        if [ $? -eq 0 ]; then
            chave="ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o HostKeyAlgorithms=+ssh-dss"
            echo -n 'Ok' >/dev/null 2>&1
        fi
    fi
    echo $chave >$arqchave
}

iniciar() {

    nomepdv=$(cat /etc/hostname)
    rm -Rf $path
    if [ ! -d "$path" ]; then
        mkdir -p $path
    fi
    cd $path
    if [[ ! -d "$nomepdv" ]]; then
        mkdir -p $nomepdv
    fi

}

getserv() {

    servidor=$(cat $arqbkp | grep "SERVIDOR" | cut -d '=' -f 2)
    ping -c 2 -w 4 $servidor >/dev/null 2>&1
    if [[ ! $? -eq 0 ]]; then
        yad --title="ERRO" --text="\n\t<big>IP do servidor invalido ou inacessivel.</big>" --button="gtk-close:1" --center --width=400 --height=100 --image="gtk-dialog-error"
        finalizar
        exit 1
    fi
    senhaserv=$(cat $arqbkp | grep "SENHA" | cut -d '=' -f 2)

}

mysqlbkp() {

    mysqldump -u$user -p$pass $banco >$path/$nomepdv/masterbox.sql
    if [ ! $? -eq 0 ]; then
        yad --title="ERRO" --text="\n\t<big>Falha ao realizar backup do pdv.</big>" --button="gtk-close:1" --center --width=400 --height=100 --image="gtk-dialog-error"
        finalizar
        exit 1
    fi

}

autobkp() {
    
    echo
    echo " --> INICIANDO PROCESSO DE BACKUP. <--"
    echo " --> NAO DESLIGUE O PDV. <--"
    echo
    echo "Criando pastas."
    iniciar
    echo "OK!"
    echo
    echo "Configurando dependencias."
    depSsh
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

bkpdiario() {

    diario=$(cat $arqbkp | grep "DIARIO" | cut -d '=' -f 2)
    if [[ $diario -ge 1 ]]; then
        rm $arqshut
        touch $arqshut
        chmod +x $arqshut
        echo "#!/bin/bash" >>$arqshut
        echo "backuppdv autobkp" >>$arqshut
        yad --title="BACKUP DIARIO" --text="\n\n\t<big>BACKUP DIARIO ATIVADO.</big>" --button="gtk-close:1" --center --width=400 --height=50 --image="gtk-save-as"
    fi
    if [[ $diario -le 0 ]]; then
        rm $arqshut
        touch $arqshut
        chmod +x $arqshut
        echo "#!/bin/bash" >>$arqshut
        echo "shutdown -h now" >>$arqshut
        yad --title="BACKUP DIARIO" --text="\n\n\t<big>BACKUP DIARIO DESATIVADO.</big>" --button="gtk-close:1" --center --width=400 --height=50 --image="gtk-save-as"
    fi

}

envbkp() {

    cd $path
    touch lojas.sql
    echo "select cnpj from loja" >> lojas.sql
    mysql -u$user -p$pass masterbox < lojas.sql > loja.sql
    loja=$(cat loja.sql |grep -vEi "cnpj")
    cp $regedit $path/$nomepdv
    cp $masterbox/MasterBox.exe $path/$nomepdv
    cp $masterbox/MasterBox.ini $path/$nomepdv
    cp -r $masterbox/tema $path/$nomepdv
    tar cvzf ${nomepdv}_${loja}.tar.gz $nomepdv/ >/dev/null 2>&1
    sshpass -p "$senhaserv" scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o HostKeyAlgorithms=+ssh-dss $chave ${nomepdv}_${loja}.tar.gz root@$servidor:$pathbkp >/dev/null 2>&1

}

rbackupconfirma() {

    yad --title="RESTAURACAO DE BACKUP DO PDV" --center --button="Não"!gtk-cancel:1 --button="Sim"!gtk-ok:0 --text="\nDeseja realmente <b>RESTAURAR</b> o backup do pdv?" --image=gtk-execute --width=400 --escape-ok
    if [ $? == 0 ]; then
        rbackuppdv | yad --text-info --tail --title="RESTAURACAO DE BACKUP DO PDV" --width="400" --height="350" --button="gtk-close:1" --center --no-buttons --auto-close
    fi

}

rbackuppdv() {

    echo
    echo "Iniciando processo de restauração."
    echo
    echo "Criando pastas."
    iniciar
    echo "OK!"
    echo
    echo "Configurando dependencias."
    depSsh
    echo "OK!"
    echo
    echo "Obtendo arquivo de configuração."
    getserv
    echo "OK!"
    echo
    echo "Obtendo backup."
    cd $path/$nomepdv
    rm $path/$nomepdv/*
    sshpass -p "$senhaserv" scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o HostKeyAlgorithms=+ssh-dss $chave root@$servidor:/$pathbkp/$nomepdv.tar.gz $path/$nomepdv >/dev/null 2>&1
    echo "OK!"
    echo
    echo "Descompactando backup e copiando arquivos."
    tar xzf $nomepdv.tar.gz
    cd $nomepdv
    cp system.reg $regedit
    cp MasterBox.exe $masterbox
    cp MasterBox.ini $masterbox
    cp -r tema/ $masterbox
    echo "CREATE DATABASE IF NOT EXISTS masterbox CHARACTER SET DEFAULT COLLATE DEFAULT;" >>criadb.sql
    mysql -uroot -p152100 <criadb.sql
    mysql -uroot -p152100 masterbox <masterbox.sql
    /opt/cxoffice/bin/cxreboot >/dev/null 2>&1
    echo "OK!"
    echo
    echo " --> RESTAURACAO REALIZADA COM SUCESSO. <--"
    echo
    echo " --> ESC PARA CONTINUAR. <--"

}

editarbkp() {

    backup=$(cat $arqbkp | grep "BACKUP")
    if [[ -z $backup ]]; then
    rm $arqbkp
    touch $arqbkp
    chmod 777 $arqbkp
    echo "[BACKUP]" >> $arqbkp
    echo "SERVIDOR=" >> $arqbkp
    echo "SENHA=" >> $arqbkp
    echo "DIARIO=0" >> $arqbkp
    leafpad $arqbkp
    else
    leafpad $arqbkp
    fi

}

cmanualbkpconfirma() {

    yad --title="BACKUP MANUAL DO PDV" --center --button="Não"!gtk-cancel:1 --button="Sim"!gtk-ok:0 --text="\nDeseja realmente fazer o <b>BACKUP</b> do pdv?" --image=gtk-execute --width=400 --escape-ok
    if [ $? == 0 ]; then
        cmanualbkp | yad --text-info --tail --title="BACKUP MANUAL DO PDV" --width="400" --height="350" --button="gtk-close:1" --center --no-buttons --auto-close
    fi

}

cmanualbkp() {

    echo
    echo "Iniciando processo de backup manual."
    echo
    echo "Criando pastas."
    iniciar
    echo "OK!"
    echo
    echo "Obtendo arquivo de configuração."
    getserv
    echo "OK!"
    echo
    echo "Configurando dependencias."
    depSsh
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

criamdb() {

    $servicemdb stop >/dev/null 2>&1
    sed -i 's\skip-grant-tables.*\#skip-grant-tables\' $confmdb
    $servicemdb start >/dev/null 2>&1
    touch $arqcriamdb
    echo "create database masterbox;" >> $arqcriamdb
    mysql -u$user -p$pass < $arqcriamdb
    $servicemdb stop >/dev/null 2>&1
    sed -i 's\#skip-grant-tables.*\skip-grant-tables\' $confmdb
    $servicemdb start >/dev/null 2>&1

}

#####################################################################################################

case $1 in

autobkp)
    autobkp | yad --text-info --tail --title="BACKUP DO PDV" --width="400" --height="350" --button="gtk-close:1" --center --no-buttons --auto-close
    ;;
mnbackuppdv)
    numlockx on
    mnbackuppdv
    ;;
bkpdiario)
    bkpdiario
    ;;
editarbkp)
    editarbkp
    ;;
criamdb)
    criamdb
    ;;
esac
