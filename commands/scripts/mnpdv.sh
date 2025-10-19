#!/bin/bash

export LOGO="/usr/share/aramo/mnpdv.png"

confpdv() {
	while :; do
		local IPLOCAL=$(ip a | grep -i "inet" | grep -vi "inet6" | grep -vi "127.0.0.1" | awk '{print $2}' | cut -d "/" -f 1)
		local OPCAO7=$(yad --image="preferences-other" --image-on-top \
			--undecorated --center --height=280 --borders=5 \
			--text="\n<b><big>Configuracao do Pdv</big></b>\n\n" --text-align=center --on-top \
			--form \
			--field=$"Numero do pdv: :num" ${pdv:-001!1..999} \
			--field=$"Codigo da Empresa: :num" ${emp:-001!1..999} \
			--field=$"Ip do Servidor: <br>" "${srv:-192.168.1.250}")
		[[ -z ${OPCAO7} ]] && break
		local PDV=$(echo ${OPCAO7} | cut -d "|" -f 1)
		local LOJA=$(echo ${OPCAO7} | cut -d "|" -f 2)
		local IP=$(echo ${OPCAO7} | cut -d "|" -f 3)
		if [[ -z ${PDV} ]] || [[ -z ${LOJA} ]] || [[ -z ${IP} ]]; then
			break
		fi
		PDV=$(printf "%03d\n" ${PDV} <<<echo)
		LOJA=$(printf "%03d\n" ${LOJA} <<<echo)
		VERF=$(echo $IP | grep -Ei '^([0-9]{1,3}[.]){3}[0-9]{1,3}$')
		if [[ -z ${VERF} ]]; then
			yad --center --height=90 --width=240 --undecorated --text "\n<b><big> Atencao!!!\n</big></b>\n\nIP Invalido" --button="Fechar!window-close:1" --image="dialog-warning"
			continue
		fi
		yad --center --height=90 --width=240 --undecorated --text "\n<b><big>Configuração\n</big></b>\n\ \
																	<b><big>Confirma as Informações Digitadas?</big></b>\n \
																	<b><big>PDV:\t</big></b>$(echo ${PDV}) \
																	<b><big>LOJA:\t</big></b>$(echo ${LOJA}) \
																	<b><big>IP:\t\t</big></b>$(echo ${VERF})\n" --button="Não!window-close:1" --button="Sim!media-playback-start:2" --image="dialog-warning"
		if [[ $? == "2" ]]; then
			cat >/usr/aramo/pdv/pdv.conf <<EOF
[Geral]
Empresa			= ${LOJA}
PDV			= ${PDV}
IpServidor		= ${VERF}
PortaServidor		= 8080
IpLocal			= ${IPLOCAL}
EOF
			addchave
			break
		fi
	done
}

confm4() {
	while :; do
		OPCAO2=$(yad --image=${LOGO} --image-on-top \
			--list --undecorated \
			--width=520 --height=310 --center \
			--column='':NUM --column='                          Selecione uma das opcoes':TEXT \
			--search-column=1 --no-buttons --borders=5 --no-escape \
			--window-icon="" --no-headerss --print-column=1 --separator='' --hide-column=0 \
			1 '<big>Configurar Pdv.conf</big>' \
			2 '<big>Configurar Clisitef.ini</big>' \
			3 '<big>Backup PDV</big>' \
			4 '<big>Voltar</big>')
		[[ -z $OPCAO2 ]] && break
		case "$OPCAO2" in
		1)
			confpdv
			;;
		2)
			gvim /usr/aramo/pdv/CliSiTef.ini
			;;
		3)
			backuppdv mnbackuppdv
			;;
		4)
			break
			;;
		esac
	done
}

confrede() {
	while :; do
		OPCAO4=$(yad --image=${LOGO} --image-on-top \
			--list --undecorated \
			--width=520 --height=330 --center \
			--column='':NUM --column='                          Selecione uma das opcoes':TEXT \
			--search-column=1 --no-buttons --borders=5 --no-escape \
			--window-icon="" --no-headerss --print-column=1 --separator='' --hide-column=0 \
			1 '<big>Alterar IP</big>' \
			2 '<big>Alterar Nome da Maquina</big>' \
			3 '<big>Reiniciar Rede</big>' \
			4 '<big>Status da Rede</big>' \
			5 '<big>Voltar</big>')
		[[ -z $OPCAO4 ]] && break
		case "$OPCAO4" in
		1)
			redeedit ip
			;;
		2)
			redeedit nome
			;;
		3)
			redeedit reset
			;;
		4)
			redeedit info
			;;
		5)
			break
			;;
		esac
	done
}

tecnico() {
	while :; do
		OPCAO=$(yad --image=${LOGO} --image-on-top \
			--list --undecorated \
			--width=520 --height=490 --center \
			--column='':NUM --column='                          Selecione uma das opcoes':TEXT \
			--search-column=1 --no-buttons --borders=5 --no-escape \
			--window-icon="" --no-headerss --print-column=1 --separator='' --hide-column=0 \
			1 '<big>Configurar Rede</big>' \
			2 '<big>Configurar M4</big>' \
			3 '<big>Serial Localizada</big>' \
			4 '<big>Putty</big>' \
			5 '<big>Gerenciador de Arquivos</big>' \
			6 '<big>Terminal</big>' \
			7 '<big>Voltar</big>')
		case "$OPCAO" in
		1)
			confrede
			;;
		2)
			confm4
			;;
		3)
			infoser
			;;
		4)
			putty
			;;
		5)
			thunar
			;;
		6)
			xterm -T aramo -fn 1x2 -geometry 130x30+110+190
			;;
		7)
			break
			;;
		esac
	done
}

senha() {
	from1=$(
		yad --image="system-lock-screen-symbolic" \
			--center --title="CONFIGURACAO TECNICA" \
			--text='Digite a Senha ou                     Tecle ESC para voltar.' --undecorated \
			--width=280 --height=100 --no-buttons \
			--form --field="":H --hide-text \ 
		--entry-label ""
	)
	pass=$(echo "${from1}" | cut -d "|" -f 1)
	if [[ ${pass} == "152100" ]]; then
		tecnico
	else
		yad --center --height=90 --width=240 --undecorated --text "\n<b><big> Atencao!!!\n</big></b>\n\nSenha Invalida" --button="Fechar!window-close:1" --image="dialog-warning"
	fi
}

inicia_updv() {
	PIDOPEN=$(ps -ef | grep "/usr/bin/openbox" | head -1 | awk '{print $2}')
	PIDSP=$(ps -eo comm | grep updv)
	CAMINHO="/usr/aramo/pdv"
	if [ -z $PIDSP ]; then
		pushd $CAMINHO >/dev/null
		if [ -e $CAMINHO/pdv.conf ]; then
			IPLOCAL=$(cat ${CAMINHO}/pdv.conf | grep -i "iplocal" | awk '{print $3}')
			if [ $IPLOCAL == "10.10.10.10" ]; then
				IP=$(ip a | grep -i "inet" | grep -vi "inet6" | grep -vi "127.0.0.1" | awk '{print $2}' | cut -d "/" -f 1)
				if [ $IP == "10.10.10.10" ]; then
					yad --center --height=90 --width=240 --undecorated --text "\n<b><big> Atencao!!!\n</big></b>\n\nRede não Configurada" --button="Fechar!window-close:1" --image="dialog-warning"
					return
				fi
				sed -i "s/IpLocal.*/IpLocal                 = ${IP}/" $CAMINHO/pdv.conf
			fi
		else
			yad --center --height=90 --width=240 --undecorated --text "\n<b><big> Atencao!!!\n</big></b>\n\nArquivo de configuracao do pdv não encontrado" --button="Fechar!window-close:1" --image="dialog-warning"
			return
		fi
		# Corrige problema de perder conexão com a impressora usb
		for i in /sys/bus/usb/devices/usb*/power/control; do
			echo "on" >$i
		done
		# Verifica e apaga logs com mais de 30 dias
		find /usr/aramo/pdv/logs/ -type f -atime +30 -exec /bin/rm -f {} \;
		find /tmp/.backuppdv/ -type f -atime +30 -exec /bin/rm -f {} \;
		# Verificando se existe a pasta de logs
		[[ ! -e ./logs ]] && mkdir logs
		# Executa o sp2
		./updv debug
		popd >/dev/null
	fi
}

menu() {
	while :; do
		OPCAO1=$(yad --image=${LOGO} --image-on-top \
			--list --undecorated \
			--width=520 --height=330 --center \
			--column='':NUM --column='                          Selecione uma das opcoes':TEXT \
			--search-column=1 --no-buttons --borders=5 --no-escape \
			--window-icon="" --no-headerss --print-column=1 --separator='' --hide-column=0 \
			1 '<big>Inicia o PDV</big>' \
			2 '<big>Reiniciar PDV</big>' \
			3 '<big>Desligar PDV</big>' \
			4 '<big>Configuracao Tecnica</big>' \
			5 '<big>Status de Rede</big>')
		case "$OPCAO1" in
		1)
			inicia_updv
			;;
		2)
			shutdown -r now
			;;
		3)
			backuppdv autobkp
			shutdown -h now
			;;
		4)
			senha
			;;
		5)
			redeedit info
			;;
		esac
	done
}

numlockx on
menu
