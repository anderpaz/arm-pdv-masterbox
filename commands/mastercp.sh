#!/bin/bash
path="/tmp/.copyMaster"
sql="$path/sql"
sqlget="$path/sqlget"
arq="$path/MASTERBOX"
arqchave="$path/chave"
log="/tmp/copyMaster.log"
update="/tmp/sqlset.sql"
banco="masterbox"
regedit="/root/.cxoffice/Aramo/system.reg"
user="root"
pass="152100"
VERDE="\033[32m"
VERMELHO="\033[31m"
NORMAL="\033[0m"
AMARELO="\033[33m"

finalizar(){
	rm -Rf $path > /dev/null 2>&1
}

versao(){
        teste=$(sshpass -p "152100" ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $ip cat /etc/issue)
        if echo $teste |grep Masterbox > /dev/null; then
	        echo
	else
	        yad --title="ERRO" --text="\n\t<big>Versao do host incompativel.\n\nHost informado:<b> $(echo $ip)</b></big>" --button="gtk-close:1" --center --width=400 --height=100 --image="gtk-dialog-error"
	        finalizair
	        exit 1
	fi
}

iniciar(){
	pdvrestart kill
	rm -Rf $path
	rm -Rf $log
	if [ ! -d "$path" ]; then
		mkdir -p $path
		mkdir -p $arq
	fi
	echo > $log 2>&1
}

depSsh(){
	echo
	chave=''
	echo '' > $arqchave
	if [ -z $chave ]; then
		echo -n 'ssh =+ 1 : ' >> $log 2>&1
		sshpass -p "152100" ssh  -o ConnectTimeout=5 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $ip echo >> $log 2>&1
		if [ $? -eq 0 ]; then
			chave="ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
			echo -n 'Ok' >> $log 2>&1
		fi
	fi
	echo
	if [ -z $chave ]; then
		echo -n 'ssh =+ 2 : ' >> $log 2>&1
		sshpass -p "152100" ssh  -o ConnectTimeout=5 -o HostKeyAlgorithms=+ssh-dss -o StrictHostKeyChecking=no $ip echo >> $log 2>&1
		if [ $? -eq 0 ]; then
			chave="ssh -o HostKeyAlgorithms=+ssh-dss"
			echo -n 'Ok' >> $log 2>&1
		fi
	fi
	echo
	if [ -z $chave ]; then
		echo -n 'ssh =+ 3 : ' >> $log 2>&1
		sshpass -p "152100" ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o HostKeyAlgorithms=+ssh-dss $ip echo >> $log 2>&1
		if [ $? -eq 0 ]; then
			chave="ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o HostKeyAlgorithms=+ssh-dss"
			echo -n 'Ok' >> $log 2>&1
		fi
	fi
	echo $chave > $arqchave
}

validRede(){
	if ! echo $ip |egrep -q '^(([0-9]{1,2}|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.){3}([0-9]{1,2}|1[0-9][0-9]|2[0-4][0-9]|25[0-4])$'; then
		yad --title="ERRO" --text="\n\t<big>Endereço IP informado é invalido.\n\nValor informado:<b> $(echo $ip)</b></big>" --button="gtk-close:1" --center --width=400 --height=100 --image="gtk-dialog-error"
		finalizar
		exit 1
	fi
	ping -c 2 -w 4 $ip >> $log 2>&1
	if [ ! $? -eq 0 ]; then
		yad --title="ERRO" --text="\n\t<big>Host de destino inacessivel.\n\nValor informado:<b> $(echo $ip)</b></big>" --button="gtk-close:1" --center --width=400 --height=100 --image="gtk-dialog-error"
		finalizar
		exit 1
	fi
}

validId(){
	if [[ ! $id = ?(+|-)+([0-9]) ]] || [ "$(echo $id | wc -c)" -ge 5 ] ; then 
		yad --title="ERRO" --text="\n\t<big>ID do pdv informado é invalido.\n\nValor informado:<b> $(echo $id)</b></big>" --button="gtk-close:1" --center --width=400 --height=100 --image="gtk-dialog-error"
		finalizar
		exit 1
	fi
}

validIdLoja(){

	if [[ ! $idloja = ?(+|-)+([0-9]) ]] || [ "$(echo $idloja | wc -c)" -ge 5 ] ; then 
		yad --title="ERRO" --text="\n\t<big>IDLOJA do pdv informado é invalido.\n\nValor informado:<b> $(echo $idloja)</b></big>" --button="gtk-close:1" --center --width=400 --height=100 --image="gtk-dialog-error"
		finalizar
		exit 1
	fi
}

ipCaixa(){

	FORM=$(yad --form --center --button="gtk-cancel:1"  --button="Salvar"!gtk-ok --width=500 --title="MENU DE COPIA" --text="\n\t<b>IP do caixa para copia:</b>\t<b>$nome</b>\n\n" --field="" --image="system")
	ip=$(echo "$FORM" | cut -d "|" -f 1)
	if [ -z $ip ];then
		finalizar
		exit 1
	fi
}

idLocal(){

	ID=$(yad --form --center --button="gtk-cancel:1"  --button="Salvar:0"!gtk-ok --width=500 --title="MENU DE COPIA" --text="\n\t<b>ID do PDV que esta sendo instalado.</b>\t<b>$nome</b>\n\n" --field="ID NOVO PDV:":N --image="system")
	id=$(echo "$ID" | cut -d "|" -f 1)
	validId $id

}

idLojaLocal(){

	IDLOJA=$(yad --form --center --button="gtk-cancel:1"  --button="Salvar:0"!gtk-ok --width=500 --title="MENU DE COPIA" --text="\n\t<b>IDLOJA da LOJA que esta sendo instalado.</b>\t<b>$nome</b>\n\n" --field="QUAL É O ID DA LOJA?:":N --image="system")
	idloja=$(echo "$IDLOJA" | cut -d "|" -f 1)
	validIdLoja $idloja
}

copyget(){
	sshpass -p "152100" rsync -rv -e "$chave" root@$ip:/root/.cxoffice/Aramo/system.reg $path/system.reg >> $log 2>&1
	if [ ! $? -eq 0 ]; then
	        yad --title="ERRO" --text="\n\n\t<b><big>Erro ao realizar download\n\tdo caixa de destino</big></b>" --button="gtk-close:1" --center --width=400 --height=50 --image="gtk-dialog-error"
		finalizar
		exit 1
	fi
	cd $arq
	mv tema oldtema
	sshpass -p "152100" rsync --exclude={BKPX*,NFCe*,LOG*,STAT*,Bkp*,MASTERBOXNOVO*,*.log*,*.LOG,*.old*,*.Old,*.OLD,*.oo,*.OO,*.dd,*.DD,CARGA*} -rv -e "$chave" root@$ip:/mnt/Aramo/MASTERBOX/* $arq >> $log 2>&1
	if [ ! $? -eq 0 ]; then
	        yad --title="ERRO" --text="\n\n\t<b><big>Erro ao realizar download\n\tdo caixa de destino</big></b>" --button="gtk-close:1" --center --width=400 --height=50 --image="gtk-dialog-error"
		finalizar
		exit 1
	fi
	sshpass -p "152100" rsync -rv -e "$chave" root@$ip:/root/.cxoffice/Aramo/drive_c/wallpaper.bmp $path/ >> $log 2>&1
	if [ ! $? -eq 0 ]; then
	        yad --title="ERRO" --text="\n\n\t<b><big>Erro ao realizar download\n\tdo caixa de destino</big></b>" --button="gtk-close:1" --center --width=400 --height=50 --image="gtk-dialog-error"
		finalizar
		exit 1
	fi
}

copygetsreg(){

	cd $arq
	mv tema oldtema
	sshpass -p "152100" rsync --exclude={BKPX*,NFCe*,LOG*,STAT*,Bkp*,MASTERBOXNOVO*,*.log*,*.LOG,*.old*,*.Old,*.OLD,*.oo,*.OO,*.dd,*.DD,CARGA*} -rv -e "$chave" root@$ip:/mnt/Aramo/MASTERBOX/* $arq >> $log 2>&1
	if [ ! $? -eq 0 ]; then
	        yad --title="ERRO" --text="\n\n\t<b><big>Erro ao realizar download\n\tdo caixa de destino</big></b>" --button="gtk-close:1" --center --width=400 --height=50 --image="gtk-dialog-error"
		finalizar
		exit 1
	fi
	sshpass -p "152100" rsync -rv -e "$chave" root@$ip:/root/.cxoffice/Aramo/drive_c/wallpaper.bmp $path/ >> $log 2>&1
	if [ ! $? -eq 0 ]; then
	        yad --title="ERRO" --text="\n\n\t<b><big>Erro ao realizar download\n\tdo caixa de destino</big></b>" --button="gtk-close:1" --center --width=400 --height=50 --image="gtk-dialog-error"
		finalizar
		exit 1
	fi

}

configget() {

	mysqldump -h$ip -u$user -p$pass $banco config > $update 
	if [ ! $? -eq 0 ]; then	
		yad --title="ERRO" --text="\n\t<big><b>Erro ao atualizar tabela CONFIG</b></big>" --button="gtk-close:1" --center --width=400 --height=100 --image="gtk-dialog-error"
		finalizar
		exit 1
	fi
	numcoluna=$(cat $sqlget | awk '{print NF}' | sed -n '2p')

	cont="1"
	while [ $cont -le $numcoluna ]; do
		coluna=$(cat $sqlget | awk '{print $'$cont'}' | sed -n '2p')
		valor=$(cat $sqlget | awk '{print $'$cont'}' | sed -n '4p')
		if [ $valor = "<null>" ]; then
			valor="null"
		else
			valor="'$valor'"
		fi
		echo "$coluna = $valor," >> $update
		let cont=$cont+1
	done	
	sed -i '$s/,/;/' $update | tail -1
	echo "commit;" >> $update

}

configset(){
	mysql -uroot -p152100 $banco < $update >> $log 2>&1
	if [ ! $? -eq 0 ]; then	
		yad --title="ERRO" --text="\n\t<big><b>Erro ao atualizar tabela CONFIG</b></big>" --button="gtk-close:1" --center --width=400 --height=100 --image="gtk-dialog-error"
		finalizar
		exit 1
	fi
}

confignovaget() {

	mysqldump -h$ip -u$user -p$pass $banco confignova > $update 
	if [ ! $? -eq 0 ]; then	
		yad --title="ERRO" --text="\n\t<big><b>Erro ao atualizar tabela CONFIGNOVA</b></big>" --button="gtk-close:1" --center --width=400 --height=100 --image="gtk-dialog-error"
		finalizar
		exit 1
	fi
	numcoluna=$(cat $sqlget | awk '{print NF}' | sed -n '2p')

	cont="1"
	while [ $cont -le $numcoluna ]; do
		coluna=$(cat $sqlget | awk '{print $'$cont'}' | sed -n '2p')
		valor=$(cat $sqlget | awk '{print $'$cont'}' | sed -n '4p')
		if [ $valor = "<null>" ]; then
			valor="null"
		else
			valor="'$valor'"
		fi
		echo "$coluna = $valor," >> $update
		let cont=$cont+1
	done	
	sed -i '$s/,/;/' $update | tail -1
	echo "commit;" >> $update

}

confignovaset(){
	mysql -uroot -p152100 $banco < $update >> $log 2>&1
	if [ ! $? -eq 0 ]; then	
		yad --title="ERRO" --text="\n\t<big><b>Erro ao atualizar tabela CONFIGNOVA</b></big>" --button="gtk-close:1" --center --width=400 --height=100 --image="gtk-dialog-error"
		finalizar
		exit 1
	fi
}

setid() {

	terminal=$(cat $regedit |grep "TERMINAL" | cut -d '=' -f 2 | cut -c -6)
	hexa=$(printf "%x" $id)

	if [ $(echo $hexa | wc -c) -eq "2" ]; then
		idpdv="0000000"$hexa
	elif [ $(echo $hexa | wc -c) -eq "3" ]; then
	        idpdv="000000"$hexa
	elif [ $(echo $hexa | wc -c) -eq "4" ]; then
                idpdv="000000"$hexa
	elif [ $(echo $hexa | wc -c) -lt "5"  ];then
		yad --title="ERRO" --text="\n\t<big>ID do pdv informado maior que 999.\n\nValor informado:<b> $(echo $id)</b></big>" --button="gtk-close:1" --center --width=400 --height=100 --image="gtk-dialog-error"
	fi
	
	if [ $(echo $id | wc -c) -eq "2" ]; then
		terminal=$terminal"00"$id
	elif [ $(echo $id | wc -c) -eq "3" ]; then
		terminal=$terminal"0"$id
	elif [ $(echo $id | wc -c) -eq "4" ]; then
                terminal=$terminal""$id
	elif [ $(echo $id | wc -c) -lt "5"  ];then
		yad --title="ERRO" --text="\n\t<big>ID do pdv informado maior que 999.\n\nValor informado:<b> $(echo $id)</b></big>" --button="gtk-close:1" --center --width=400 --height=100 --image="gtk-dialog-error"
	fi
	
	sed -i 's/"CODIGOPDV"=dword:*.*/"CODIGOPDV"=dword:'"$idpdv"'/g' $regedit
	sed -i 's/"TERMINAL"=*.*/"TERMINAL"='"$terminal"'"/g' $regedit

}

setidloja(){

	terminal=$(cat $regedit |grep "TERMINAL" | cut -d '=' -f 2 | cut -c -6)
	hexa=$(printf "%x" $idloja)

	if [ $(echo $hexa | wc -c) -eq "2" ]; then
		codigoloja="0000000"$hexa
	elif [ $(echo $hexa | wc -c) -eq "3" ]; then
	        codigoloja="000000"$hexa
	elif [ $(echo $hexa | wc -c) -eq "4" ]; then
                codigoloja="000000"$hexa
	elif [ $(echo $hexa | wc -c) -lt "5"  ];then
		yad --title="ERRO" --text="\n\t<big>IDLOJA do pdv informado maior que 999.\n\nValor informado:<b> $(echo $idloja)</b></big>" --button="gtk-close:1" --center --width=400 --height=100 --image="gtk-dialog-error"
	fi
	sed -i 's/"CODIGOLOJA"=dword:*.*/"CODIGOLOJA"=dword:'"$codigoloja"'/g' $regedit
}

copyset(){

	sshpass -p "152100" rsync -av $path/system.reg /root/.cxoffice/Aramo/system.reg >> $log 2>&1
	if [ ! $? -eq 0 ]; then
		yad --title="ERRO" --text="\n\t<big><b>Erro ao atualizar regedit\n\tna pasta local</b></big>" --button="gtk-close:1" --center --width=400 --height=100 --image="gtk-dialog-error"
		finalizar
		exit 1
	fi
	sshpass -p "152100" rsync -av $arq/* /mnt/Aramo/MASTERBOX/ >> $log 2>&1
	if [ ! $? -eq 0 ]; then
		yad --title="ERRO" --text="\n\t<big><b>Erro ao atualizar arquivos do MasterBox\n\tna pasta local</b></big>" --button="gtk-close:1" --center --width=400 --height=100 --image="gtk-dialog-error"
		finalizar
		exit 1
	fi
	sshpass -p "152100" rsync -av $path/wallpaper.bmp /root/.cxoffice/Aramo/drive_c/wallpaper.bmp >> $log 2>&1
	if [ ! $? -eq 0 ]; then
		yad --title="ERRO" --text="\n\t<big><b>Erro ao atualizar wallpaper\n\tna pasta local</b></big>" --button="gtk-close:1" --center --width=400 --height=100 --image="gtk-dialog-error"
		finalizar
		exit 1
	fi

	echo -e "COPIADO=1" >> $log 2>&1
}

copysetsreg(){

	sshpass -p "152100" rsync -av $arq/* /mnt/Aramo/MASTERBOX/ >> $log 2>&1
	if [ ! $? -eq 0 ]; then
		yad --title="ERRO" --text="\n\t<big><b>Erro ao atualizar arquivos do MasterBox\n\tna pasta local</b></big>" --button="gtk-close:1" --center --width=400 --height=100 --image="gtk-dialog-error"
		finalizar
		exit 1
	fi
	sshpass -p "152100" rsync -av $path/wallpaper.bmp /root/.cxoffice/Aramo/drive_c/wallpaper.bmp >> $log 2>&1
	if [ ! $? -eq 0 ]; then
		yad --title="ERRO" --text="\n\t<big><b>Erro ao atualizar wallpaper\n\tna pasta local</b></big>" --button="gtk-close:1" --center --width=400 --height=100 --image="gtk-dialog-error"
		finalizar
		exit 1
	fi

	echo -e "COPIADO=1" >> $log 2>&1

}

IniciaCopiaTema(){
	echo "COPIANDO TEMA"
	echo "AGUARDE..."
	sshpass -p "152100" rsync -av scp $ip:/mnt/Aramo/MASTERBOX/tema/* /mnt/Aramo/MASTERBOX/tema >> $log 2>&1

}

comregrun(){

	echo;echo "Copiando arquivos de $ip."
	echo;echo "Atualizando tabela CONFIG."
	configget
	configset
	echo "OK!"
	echo;echo "Copiando arquivos."
	copyget
	echo "OK!"
	echo;echo "Atualizando arquivos."
	copyset
	echo "OK!"
	echo;echo "Setando CODIGOPDV do PDV: $id."
	setid
	setid
	echo "OK!"
	echo;echo "Setando CODIGOLOJA do PDV: $idloja."
	setidloja
	setidloja
	echo "OK!"
	/opt/cxoffice/bin/cxreboot > /dev/null 2>&1
	echo;echo " --> COPIA REALISADA COM SUCESSO. <--"
	echo;echo " --> ESC PARA CONTINUAR. <--"
	
}

semregrun(){

	echo;echo "Copiando arquivos de $ip."
	echo;echo "Atualizando tabela CONFIG."
	configget
	configset	
	echo "OK!"
	echo;echo "Copiando arquivos."
	copygetsreg
	echo "OK!"
	echo;echo "Atualizando arquivos."
	copysetsreg
	echo "OK!"
	/opt/cxoffice/bin/cxreboot > /dev/null 2>&1
	echo;echo " --> COPIA REALISADA COM SUCESSO. <--"
	echo;echo " --> ESC PARA CONTINUAR. <--"
	
}

configrun(){

	echo;echo "Copiando arquivos de $ip."
	echo;echo "Atualizando tabela CONFIG."
	configget
	configset		
	echo "OK!"
	echo;echo " --> COPIA REALIZADA COM SUCESSO. <--"
	echo;echo " --> ESC PARA CONTINUAR. <--"

}

confignovarun(){

	echo;echo "Copiando arquivos de $ip."
	echo;echo "Atualizando tabela CONFIGNOVA."	
	confignovaget
	confignovaset	
	echo "OK!"
	echo;echo " --> COPIA REALIZADA COM SUCESSO. <--"
	echo;echo " --> ESC PARA CONTINUAR. <--"
}

todasconfigrun() {

	echo;echo "Copiando arquivos de $ip."
	echo;echo "Atualizando tabela CONFIG."
	configget
	configset
	echo "OK!"
	echo;echo "Atualizando tabela CONFIGNOVA."
	confignovaget
	confignovaset	
	echo "OK!"
	echo;echo " --> COPIA REALIZADA COM SUCESSO. <--"
	echo;echo " --> ESC PARA CONTINUAR. <--"

}

conectar() {

	depSsh
	if [ "$(cat $arqchave | wc -c)" -lt 5 ]; then
		yad --title="ERRO" --text="\n\t<big>Host informado inacessivel.\n\nValor informado: <b>$ip</b></big>" --button="gtk-close:1" --center --width=400 --height=100 --image="gtk-dialog-error"
		finalizar
		exit 1
	else
		chave=$(cat $arqchave)
		rm $arqchave -f
	fi

}

menugeral() {

	while :; do
		OPCAO6=$(
			yad --list \
				--title=" CONFIGURAÇÃO MASTERBOX " --text='Tecle ESC para voltar.' \
				--width=280 --height=320 --center \
				--column='OPCAO6':NUM --column='texto':TEXT \
				--window-icon="" --no-headers --print-column=1 --separator='' --hide-column=1 \
				601 '<big>Sem regedit</big>' \
				602 '<big>Com regedit</big>'\
				603 '<big>Tema</big>'
		)
		[ $? -ne 0 ] && break
		case "$OPCAO6" in
		601)
			semreg
			;;
		602)
			comreg
			;;
		603)
			CopiaTema
			;;
		esac
	done

}

CopiaTema(){

	iniciar
	ipCaixa
	validRede
	conectar
	versao
	IniciaCopiaTema | yad --text-info --tail --title="COPIANDO CONFIG E ARQUIVOS" --width="400" --height="350" --button="gtk-close:1" --center --no-buttons --auto-close
}

comreg(){

	iniciar
	ipCaixa
	validRede
	conectar
	versao
	idLocal
	validId
	idLojaLocal
	validIdLoja
	comregrun | yad --text-info --tail --title="COPIANDO CONFIG E ARQUIVOS" --width="400" --height="350" --button="gtk-close:1" --center --no-buttons --auto-close

}

semreg() {

	iniciar
	ipCaixa
	validRede
	conectar
	versao
	semregrun | yad --text-info --tail --title="COPIANDO CONFIG E ARQUIVOS" --width="400" --height="350" --button="gtk-close:1" --center --no-buttons --auto-close

}

banco() {

	iniciar
	ipCaixa
	validRede
	conectar
	versao
	configrun | yad --text-info --tail --title="COPIANDO CONFIG" --width="400" --height="300" --button="gtk-close:1" --center --no-buttons --auto-close

}

confignova() {

	iniciar
	ipCaixa
	validRede
	conectar
	versao
	confignovarun | yad --text-info --tail --title="COPIANDO CONFIGNOVA" --width="400" --height="300" --button="gtk-close:1" --center --no-buttons --auto-close

}

todasconfig() {

	iniciar
	ipCaixa
	validRede
	conectar
	versao
	todasconfigrun | yad --text-info --tail --title="COPIANDO TABELAS DE CONFIGURACAO" --width="400" --height="300" --button="gtk-close:1" --center --no-buttons --auto-close

}

case $1 in

	banco)
		banco
	;;
	menugeral)
		menugeral
	;;
	confignova)
		confignova
	;;
	todasconfig)
		todasconfig
	;;
esac
finalizar
exit 0
