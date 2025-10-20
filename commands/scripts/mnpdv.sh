#!/bin/bash

regedit="/root/.cxoffice/Aramo/system.reg"
ftpHost=ftp://177.220.191.11
ftpUser=anderson
ftpSenha=Alfa152100
ftpander=anderson
masterbox=MasterBox.zip
m5=M5.zip

#MENU PRINCIPAL
##############################################################################################################
tecnico() {
	while :; do
		OPCAO=$(
			yad --list \
				--title=" 	MENU" --text='Tecle ESC para voltar.' \
				--width=300 --height=560 --center \
				--column='OPCAO':NUM --column='texto':TEXT \
				--window-icon="" --no-headers --print-column=1 --separator='' --hide-column=1 \
				1 '<big>Regedit</big>' \
				2 '<big>MasterBox</big>' \
				3 '<big>Configurar Rede</big>' \
				4 '<big>Configurar MasterBox</big>' \
				5 '<big>Configurar USB</big>' \
				6 '<big>Manutenção MasterBox</big>' \
				7 '<big>HeidiSQL</big>' \
				8 '<big>Serial Localizada</big>' \
				9 '<big>Putty</big>' \
				10 '<big>Gerenciador de Arquivos</big>' \
				11 '<big>Terminal</big>' \
				12 '<big>Reiniciar PDV</big>' \
				13 '<big>Desligar PDV</big>'
		)
		[ $? -ne 0 ] && break
		case "$OPCAO" in
		1)
			wine regedit &&
				yadsair
			;;
		2)
			resetmaster
			break
			;;
		3)
			confrede &&
				yadsair
			;;
		4)
			confmaster &&
				yadsair
			;;
		5)
			confusb &&
				yadsair
			;;
		6)
			manutmaster &&
				yadsair
			;;
		7)
			wine /root/.cxoffice/Aramo/drive_c/windows/HeidiSQL/heidisql.exe &&
				yadsair
			;;
		8)
			infoser &&
				yadsair
			;;
		9)
			putty &&
				yadsair
			;;
		10)
			thunar /mnt/Aramo/MASTERBOX/ &&
				yadsair
			;;
		11)
			x-terminal-emulator &&
				yadsair
			;;
		12)
			shutdown -r now
			;;
		13)
			shutdown -h now
			;;
		esac
	done
}

senha() {

	from1=$(yad --center --title="CONFIGURACAO TECNICA" --text='Tecle ESC para voltar.' --form --field="":H --hide-text --entry-label "" --image="gtk-dialog-authentication")
	pass=$(echo "$from1" | cut -d"|" -f 1)
	if [[ $pass == "152100" ]]; then
		tecnico
	else
		echo
	fi

}

menu() {

	while :; do
		OPCAO1=$(
			yad --list \
				--title="	MENU" --text='Tecle ESC para sair.' \
				--width=280 --height=320 --center \
				--column='OPCAO1':NUM --column='texto':TEXT \
				--window-icon="" --no-headers --print-column=1 --separator='' --hide-column=1 \
				101 '<big>Configuracao Tecnica</big>' \
				102 '<big>MasterBox</big>' \
				103 '<big>Status de Rede</big>' \
				104 '<big>Reiniciar PDV</big>' \
				105 '<big>Desligar PDV</big>'
		)
		[ $? -ne 0 ] && break
		case "$OPCAO1" in
		101)
			senha
			;;
		102)
			resetmaster
			break
			;;
		103)
			redeedit info
			;;
		104)
			shutdown -r now
			;;
		105)
			shutdown -h now
			;;
		esac
	done

}

confrede() {
	while :; do
		OPCAO4=$(
			yad --list \
				--title=" CONFIGURAÇÃO DE REDE " --text='Tecle ESC para voltar.' \
				--width=280 --height=320 --center \
				--column='OPCAO4':NUM --column='texto':TEXT \
				--window-icon="" --no-headers --print-column=1 --separator='' --hide-column=1 \
				401 '<big>Alterar IP</big>' \
				402 '<big>Alterar Nome da Maquina</big>' \
				403 '<big>Reiniciar Rede</big>' \
				404 '<big>Status da Rede</big>'
		)
		[ $? -ne 0 ] && break
		case "$OPCAO4" in
		401)
			redeedit ip &&
				yadsair
			;;
		402)
			redeedit nome &&
				yadsair
			;;
		403)
			redeedit reset &&
				yadsair
			;;
		404)
			redeedit info &&
				yadsair
			;;
		esac
	done
}

confusb() {
	while :; do
		OPCAO3=$(
			yad --list \
				--title=" CONFIGURAÇÃO USB " --text='Tecle ESC para voltar.' \
				--width=280 --height=320 --center \
				--column='OPCAO3':NUM --column='texto':TEXT \
				--window-icon="" --no-headers --print-column=1 --separator='' --hide-column=1 \
				300 '<big>Enviar Autoteste</big>' \
				301 '<big>Configurar Impressora</big>' \
				302 '<big>Configurar PinPad</big>' \
				303 '<big>Configurar Balança</big>' \
				304 '<big>Restaurar Configuração USB</big>'
		)
		[ $? -ne 0 ] && break
		case "$OPCAO3" in
		300)
			usbedit imp
			;;
		301)
			usbedit validecf
			;;
		302)
			usbedit pinpad
			;;
		303)
			usbedit balanca
			;;
		304)
			usbedit reset
			;;
		esac
	done
}
copycaixa() {
	while :; do
		OPCAO6=$(
			yad --list \
				--title=" CONFIGURAÇÃO MASTERBOX " --text='Tecle ESC para voltar.' \
				--width=280 --height=320 --center \
				--column='OPCAO6':NUM --column='texto':TEXT \
				--window-icon="" --no-headers --print-column=1 --separator='' --hide-column=1 \
				601 '<big>Copiar config do banco</big>' \
				602 '<big>Copiar arquivos e configurações</big>'
		)
		[ $? -ne 0 ] && break
		case "$OPCAO6" in
		601)
			mastercp banco
			;;
		602)
			mastercp menugeral
			;;
		esac
	done
}

confmaster() {
	while :; do
		OPCAO2=$(
			yad --list \
				--title=" CONFIGURAÇÃO MASTERBOX " --text='Tecle ESC para voltar.' \
				--width=280 --height=320 --center \
				--column='OPCAO2':NUM --column='texto':TEXT \
				--window-icon="" --no-headers --print-column=1 --separator='' --hide-column=1 \
				200 '<big>Backup PDV</big>' \
				201 '<big>Configurar MasterBox.ini</big>' \
				202 '<big>Configurar Clisitef.ini</big>' \
				203 '<big>Copiar Caixa</big>' \
				204 '<big>Configura regedit mariadb</big>' \
				205 '<big>Configura M5</big>' \
				206 '<big>Configura M3</big>' \
				207 '<big>Atualizar MasterBox</big>'
		)
		[ $? -ne 0 ] && break
		case "$OPCAO2" in
		200)
			backuppdv mnbackuppdv
			;;
		201)
			leafpad /mnt/Aramo/MASTERBOX/MasterBox.ini
			;;
		202)
			leafpad /mnt/Aramo/MASTERBOX/CliSiTef.ini
			;;
		203)
			copycaixa
			;;
		204)
			confreg | yad --text-info --tail --title="CONFIGURA REGEDIT MARIADB" --width="400" --height="350" --button="gtk-close:1" --center --no-buttons --auto-close
			;;
		205)
			confm5confirma
			;;
		206)
			confm3confirma
			;;
		207)
			atualizar
			;;
		esac
	done
}

confm3confirma() {

    yad --title="CONFIGURAR MASTERBOX" --center --button="Não"!gtk-cancel:1 --button="Sim"!gtk-ok:0 --text="\nDeseja realmente trocar de versao o masterbox do pdv?" --image=gtk-execute --width=400 --escape-ok
    if [ $? == 0 ]; then
        confm3
    fi

}

confm5confirma() {

    yad --title="CONFIGURAR MASTERBOX" --center --button="Não"!gtk-cancel:1 --button="Sim"!gtk-ok:0 --text="\nDeseja realmente trocar de versao o masterbox do pdv?" --image=gtk-execute --width=400 --escape-ok
    if [ $? == 0 ]; then
        confm5
    fi

}

confm5() {

	if [[ -e /etc/setm3 ]]; then
		cd /root/.cxoffice/Aramo/drive_c/
		mv wallpaper.bmp wallpaperm3.bmp
		mv wallpaperm5.bmp wallpaper.bmp
		cd /mnt/Aramo/MASTERBOX/
		mv tema/ temam3/
		mv temam5/ tema/
		mv MasterBox.exe MasterBoxM3.exe
		mv MasterBoxM5.exe MasterBox.exe
		mkdir BKP
		cd /mnt/Aramo/MASTERBOX/BKP/
		mysqldump -uroot -p152100 masterbox >masterbox.sql
		mv masterbox.sql `date +%Y-%m-%d.%H:%M:%S`.masterboxm3.sql
		mysql -uroot -p152100 -e "drop database masterbox;"
		mysql -uroot -p152100 -e "create database masterbox;"
		cd /usr/bin/
		chmod +x m5
		mv resetmaster resetmasterm3
		mv resetmasterm5 resetmaster 
		chmod +x /usr/bin/resetmaster
		rm /etc/setm3
		touch /etc/setm5
		m5 m5
	else
		yad --title="CONFIGURA M5" --text="\n\n\t<big>PDV JA CONFIGURADO PARA M5.</big>" --button="gtk-close:1" --center --width=500 --height=20 --image="gtk-save-as"
	fi

}

confm3() {

	if [[ -e /etc/setm5 ]]; then
		cd /root/.cxoffice/Aramo/drive_c/
		mv wallpaper.bmp wallpaperm5.bmp
		mv wallpaperm3.bmp wallpaper.bmp
		cd /mnt/Aramo/MASTERBOX/
		mv tema/ temam5/
		mv temam3/ tema/
		mv MasterBox.exe MasterBoxM5.exe
		mv MasterBoxM3.exe MasterBox.exe
		mkdir BKP
		cd /mnt/Aramo/MASTERBOX/BKP/
		mysqldump -uroot -p152100 masterbox > /mnt/Aramo/MASTERBOX/BKP/masterbox.sql
		mv masterbox.sql `date +%Y-%m-%d.%H:%M:%S`.masterboxm5.sql
		mysql -uroot -p152100 -e "drop database masterbox;"
		mysql -uroot -p152100 -e "create database masterbox;"
		cd /usr/bin/
		chmod +x m5
		mv resetmaster resetmasterm5
		mv resetmasterm3 resetmaster
		chmod +x /usr/bin/resetmaster
		rm /etc/setm5
		touch /etc/setm3
		m5 m3
	else
		yad --title="CONFIGURA M3" --text="\n\n\t<big>PDV JA CONFIGURADO PARA M3.</big>" --button="gtk-close:1" --center --width=500 --height=20 --image="gtk-save-as"
	fi

}

atualizar() {

	while :; do
		OPCAO10=$(
			yad --list \
				--title="ATUALIZAR MASTERBOX" --text='Tecle ESC para voltar.' \
				--width=280 --height=320 --center \
				--column='OPCAO2':NUM --column='texto':TEXT \
				--window-icon="" --no-headers --print-column=1 --separator='' --hide-column=1 \
				1000 '<big>Atualizar M5</big>' \
				1001 '<big>Atualizar M3</big>'
		)
		[ $? -ne 0 ] && break
		case "$OPCAO10" in
		1000)
			atualizarm5 | yad --text-info --tail --title="ATUALIZAR MASTERBOX" --width="400" --height="200" --button="gtk-close:1" --center --no-buttons --auto-close
			;;
		1001)
			atualizarm3 | yad --text-info --tail --title="ATUALIZAR MASTERBOX" --width="400" --height="200" --button="gtk-close:1" --center --no-buttons --auto-close
			;;
		esac
	done

}

atualizarm3() {

	if [[ -e /etc/setm3 ]]; then
		cd /tmp/
		echo
		echo "Realizando download do MasterBox"
		curl -u $ftpUser:$ftpSenha -O $ftpHost/$ftpander/Pdv/$masterbox
			if [[ $? -ne 0 ]]; then
				echo "Erro ao realizar download"
				echo
   				echo " --> ATUALIZACAO NAO REALIZADA. <--"
   				echo
    			echo " --> ESC PARA CONTINUAR. <--"
				exit 0
			else
			echo "OK!"
			fi
		echo
		echo "Atualizando MasterBox"
		cp $masterbox /mnt/Aramo/MASTERBOX/
		cd /mnt/Aramo/MASTERBOX/
		cp libmariadb.dll /tmp/
		unzip -o $masterbox >/dev/null 2>&1
		rm $masterbox -f
		cp /tmp/libmariadb.dll /mnt/Aramo/MASTERBOX/
		echo "OK!"
		echo
		echo " --> ATUALIZACAO REALIZADA COM SUCESSO. <--"
    	echo
    	echo " --> ESC PARA CONTINUAR. <--"
	else
		echo
		echo "PDV CONFIGURADO PARA M5!"
		echo
		echo "PARA ATUALIZAR M5 SELECIONE"
		echo "Atualizar M5" 
		echo "NO MENU ANTERIOR"
		echo
		echo "PARA ATUALIZAR M3 CONFIGURE O PDV PARA M3"
	fi

}

atualizarm5() {

	if [[ -e /etc/setm5 ]]; then
		cd /tmp/
		echo
		echo "Realizando download do MasterBox"
		curl -u $ftpUser:$ftpSenha -O $ftpHost/$ftpander/Pdv/$m5
			if [[ $? -ne 0 ]]; then
				echo "Erro ao realizar download"
				echo
   				echo " --> ATUALIZACAO NAO REALIZADA. <--"
   				echo
    			echo " --> ESC PARA CONTINUAR. <--"
				exit 0
			else
			echo "OK!"
			fi
		echo
		echo "Atualizando MasterBox"
		cp $m5 /mnt/Aramo/MASTERBOX/
		cd /mnt/Aramo/MASTERBOX/
		cp libmariadb.dll /tmp/
		unzip -o $m5 >/dev/null 2>&1
		mv MasterBox.exe MasterBox.exe.old
		mv M5.exe MasterBox.exe
		rm $m5 -f
		cp /tmp/libmariadb.dll /mnt/Aramo/MASTERBOX/
		echo "OK!"
		echo
		echo " --> ATUALIZACAO REALIZADA COM SUCESSO. <--"
    	echo
    	echo " --> ESC PARA CONTINUAR. <--"
	else
		echo
		echo "PDV CONFIGURADO PARA M3!"
		echo
		echo "PARA ATUALIZAR M3 SELECIONE"
		echo "Atualizar M3" 
		echo "NO MENU ANTERIOR"
		echo
		echo "PARA ATUALIZAR M5 CONFIGURE O PDV PARA M5"
	fi

}

confreg() {

	echo
	echo "Iniciando processo de configuração."
	echo
	echo "BANCOLOCAL=masterbox"
	echo "PASSWLOCAL=152100"
	echo "PROTOLOCAL=MariaDB-5"
	echo "SERVERLOCAL=127.0.0.1"
	echo "USERLOCAL=root"
	sed -i 's/"BANCOLOCAL"=*.*/"BANCOLOCAL"="masterbox"/g' $regedit
	sed -i 's/"PASSWLOCAL"=*.*/"PASSWLOCAL"="152100"/g' $regedit
	sed -i 's/"PROTOLOCAL"=*.*/"PROTOLOCAL"="MariaDB-5"/g' $regedit
	sed -i 's/"SERVERLOCAL"=*.*/"SERVERLOCAL"="127.0.0.1"/g' $regedit
	sed -i 's/"USERLOCAL"=*.*/"USERLOCAL"="root"/g' $regedit
	/opt/cxoffice/bin/cxreboot >/dev/null 2>&1
	echo
	echo "OK!"
	echo
	echo " --> REGEDIT CONFIGURADO COM SUCESSO. <--"
	echo
	echo " --> CONFERIR O REGEDIT DO MASTERBOX <-- "
	echo
	echo " --> ESC PARA CONTINUAR. <--"

}

manutmaster() {
	while :; do
		OPCAO5=$(
			yad --list \
				--title=" MANUTENÇÃO MASTERBOX " --text='Tecle ESC para voltar.' \
				--width=280 --height=320 --center \
				--column='OPCAO5':NUM --column='texto':TEXT \
				--window-icon="" --no-headers --print-column=1 --separator='' --hide-column=1 \
				500 '<big>Finalizar MasterBox</big>' \
				501 '<big>Log atual do MasterBox</big>'
		)
		[ $? -ne 0 ] && break
		case "$OPCAO5" in
		500)
			resetmaster kill
			;;
		501)
			leafpad /mnt/Aramo/MASTERBOX/LOG/MASTERBOX_$(date "+%Y%m%d").log
			;;
		esac
	done
}

yadsair() {

	trap "kill -USR2 $(cat /tmp/yad_pid)" EXIT

	tecnico &
	echo $! >/tmp/yad_pid

	while :; do
		sleep 1
	done

}

yad1sair() {

	trap "kill -USR2 $(cat /tmp/yad_pid)" EXIT

	menu &
	echo $! >/tmp/yad_pid

	while :; do
		sleep 1
	done

}

numlockx on
menu
