#!/bin/bash

mata_pdv()
{
    pkill -HUP updv
    sleep 0.8
    PIDSP=$(ps -eo comm | grep updv)
    [[ ! -z ${PIDSP} ]] && { kill -9 ${PIDSP} ; }
}

inicia_updv()
{
	PIDSP=$(ps -eo comm | grep updv)
	CAMINHO="/usr/aramo/pdv"
	if [ -z $PIDSP ]; then
		pushd $CAMINHO > /dev/null
			if [ -e $CAMINHO/pdv.conf ]; then
				IPLOCAL=$(cat ${CAMINHO}/pdv.conf | grep -i "iplocal" | awk '{print $3}')
				if [ $IPLOCAL == "10.10.10.10" ]; then
					IP=$(ip a | grep -i "inet" | grep -vi "inet6" | grep -vi "127.0.0.1" | awk '{print $2}' | cut -d "/" -f 1)
					if [ $IP == "10.10.10.10" ]; then 
						yad --center --height=90 --width=240 --undecorated  --text "\n<b><big> Atencao!!!\n</big></b>\n\nRede não Configurada" --button="Fechar!window-close:1" --image="dialog-warning"
						return
					fi
					sed -i "s/IpLocal.*/IpLocal                 = ${IP}/" $CAMINHO/pdv.conf 
				fi
			else
				yad --center --height=90 --width=240 --undecorated  --text "\n<b><big> Atencao!!!\n</big></b>\n\nArquivo de configuracao do pdv não encontrado" --button="Fechar!window-close:1" --image="dialog-warning"
				return
			fi
			# Corrige problema de perder conexão com a impressora usb
			for i in /sys/bus/usb/devices/usb*/power/control 
			do
				echo "on" > $i
			done
			# Verifica e apaga logs com mais de 30 dias
			find /usr/aramo/pdv/logs/ -type f -atime +30 -exec /bin/rm -f {} \;
			find /tmp/.backuppdv/ -type f -atime +30 -exec /bin/rm -f {} \;
			# Verificando se existe a pasta de logs
			[[ ! -e ./logs ]] && mkdir logs
			# Executa o sp2
			./updv debug
		popd > /dev/null
	fi
}

mata_pdv
sleep 1
inicia_updv