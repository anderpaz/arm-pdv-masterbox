#!/bin/bash

placas=$(ifconfig -a |grep 'flags' |egrep -v 'lo' |awk '{print $1}' |cut -d ":" -f1)
lista=$(echo $placas |sed 's/[ ]/;/')
arq="/etc/network/interfaces"
resolv="/etc/resolv.conf"

reiniciar(){
	placas=$(ifconfig -a |grep 'flags' |egrep -v 'lo' |awk '{print $1}' |cut -d ":" -f1)
	for i in $placas ; do
		 ip addr flush $placas
	done
	systemctl restart networking
}

redereset(){
	reiniciar | yad --undecorated --borders=15 --progress --pulsate --percentage=85 --width=300 --text="<b>\tReiniciando a rede</b>" --progress-text="Reiniciando ... Aguarde =) ..." --auto-close --auto-kill --center --no-buttons --height=80 --image="network-wired-disconnected"
}

aguarde(){
	aguardar | yad --undecorated --borders=15 --progress --pulsate --percentage=85 --width=300 --text="<b>\tReiniciando a rede</b>" --progress-text="Reiniciando ... Aguarde =) ..." --auto-close --auto-kill --center --no-buttons --height=80 --image="network-wired-disconnected"

}

aguardar(){
	sleep 4
}

setnome()
{
	nome=$(hostname)
	FORM=$(yad --form --center --undecorated \
			--button="gtk-cancel:1" --button="Salvar!gtk-ok:0" \
			--width=500 --borders=15\
			--text="\n<b><big>\t\t\t ALTERAR NOME DA MAQUINA</big></b>\n\n\nNome da Maquina Atual:\t<b>$nome</b>\n" \
			--form  --field="Novo Nome: " --image="network-wired-disconnected")
	resp=$(echo "$FORM" | cut -d "|" -f 1 | tr 'A-Z' 'a-z')
	if [ -z $resp ];then
		exit 1
	fi
	if ! echo $resp |egrep -q -v '[^0-9a-z\-]'; then
		yad --center --undecorated --width=400 --height=70 --borders=15 --text="\n<b><big> Atencao!!!\n</big></b>\n\n<big>Nome informado Invalido.\n\nInformar apenas numero e letras\nPodendo contenter o \"-\" no lugar do espaço.\n\nValor: <b>$(echo $resp)</b></big>" --button="Fechar!window-close:1"  --image="dialog-warning"
		exit 1
	else
		echo $resp > /etc/hostname
		echo $resp > /proc/sys/kernel/hostname
		sed -i '2s/.*/127.0.1.1\t'"$(hostname)"'/' /etc/hosts
		xauth generate $DISPLAY
		yad --center --undecorated --width=400 --height=30 --borders=15 --text="<big>Reinicie o PDV para aplicar as alterações.</big>" --button="Fechar!window-close:1"  --image="dialog-warning"
		exit 0;
	fi
}

validRede()
{
	echo $1
	if ! echo $1 |egrep -q "^(([0-9]{1,2}|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.){3}([0-9]{1,2}|1[0-9][0-9]|2[0-4][0-9]|25[0-4])$"; then
		yad --center --undecorated  --width=400 --height=100  --text="\n<b><big> Atencao!!!\n</big></b>\n\t<big>Faixa informada é invalida\n\nValor informado:<b> $(echo $1)</b></big>" --button="Fechar!window-close:1"  --image="dialog-warning"
		exit 1
	fi
}

ipEdit(){
	cat > $arq << EOF
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).



# source /etc/network/interfaces.d/*
# The loopback network interface
auto lo
iface lo inet loopback
EOF

	placa=$(echo $resp | cut -d "|" -f 1)
	prop=$(echo $resp | cut -d "|" -f 2)
	ip=$(echo $resp | cut -d "|" -f 3)
	mask=$(echo $resp | cut -d "|" -f 4)
	gateway=$(echo $resp | cut -d "|" -f 5)
	dns1=$(echo $resp | cut -d "|" -f 6)
	dns2=$(echo $resp | cut -d "|" -f 7)

	if [[ $prop == "DHCP" ]]; then
        cat > $arq << EOF
auto $placa 
iface $placa inet dhcp
iface $placa inet6 auto
EOF
        redereset
		exit 0
	elif [[ $prop == "Desativar" ]]; then
		ip link set enp0s8 down
		cat > $arq << EOF
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).



# source /etc/network/interfaces.d/*
# The loopback network interface
auto lo
iface lo inet loopback
EOF
		redereset
		exit 0
	fi

	if [[ -z $ip ]] || [[ -z $mask ]] || [[ -z $dns1 ]]; then
		yad --center --undecorated  --width=500 --height=30 --text="\n<b><big> Atencao!!!\n</big></b>\n\t\n<big><b>IP, Mascara ou DNS da rede não foi infomado</b></big>" --button="Fechar!window-close:1"  --image="dialog-warning"
		exit 1
	fi

	IFS=. read -r i1 i2 i3 i4 <<< $ip
	IFS=. read -r m1 m2 m3 m4 <<< $mask
	netwok=$(printf "%d.%d.%d.%d\n" "$((i1 & m1))" "$((i2 & m2))" "$((i3 & m3))" "$((i4 & m4))")
	broadcast=$(printf "%d.%d.%d.%d\n" "$((i1 | (255 - m1)))"  "$((i2 | (255 - m2)))" "$((i3 | (255 - m3)))" "$((i4 | (255 - m4)))")
	
	validRede $ip
	validRede $mask
	if [[ ! -z $gateway ]]; then validRede $gateway; fi
	if [[ ! -z $dns1 ]]; then validRede $dns1; fi
	if [[ ! -z $dns2 ]]; then validRede $dns2; fi

    cat > $arq << EOF

# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).



# source /etc/network/interfaces.d/*
# The loopback network interface

auto lo
iface lo inet loopback

auto $placa
iface $placa inet static
#Não é recomendado fazer alteracao por aqui.
#caso faça, precisa reiniciar a maquina.
	address $ip
	netmask $mask
	network $netwok
	broadcast $broadcast
	gateway $gateway
dns-nameservers $dns1 $dns2
EOF
	ifconfig $placa $ip netmask $mask
	route add default gw $gateway
	[[ ! -z $dns1 ]] &&  { echo "nameserver ${dns1}" > ${resolv} ; }
	[[ ! -z $dns2 ]] &&  { echo "nameserver ${dns2}" >> ${resolv} ; }
}

setIp()
{
	resp=$(yad --width=420 --height=400 --undecorated \
                --text="\n<b><big>\t\t\t\tREDE</big></b>\n\n<b>Configuração de Rede v2</b>\n\n" --center --borders=15 \
                --image="network-wired-disconnected" --image-to-top \
                --form --item-separator=";" \
                --field="Escolha a placa*: ":CBE $lista \
                --field="Propiedades*: ":CB "Manual;DHCP;Desativar"  \
                --field="Endereço IP*: " \
                --field="Mascara*: " \
                --field="Gateway*: " \
                --field="Dns Primario*: " \
                --field="Dns Secundario: ")

	if [ ! -z $resp ]; then
		ipEdit
		sed -i '2s/.*/127.0.1.1\t'"$(hostname)"'/' /etc/hosts
		aguarde
	fi

}

info()
{
	placas=$(ifconfig -a |grep 'flags' |egrep -v 'lo' |awk '{print $1}' |cut -d ":" -f1)
	echo -e "\n"
	echo -e "<b>Nome da Maquina:  </b>$(hostname)\n"
	for placa in $placas; do
		echo -e "<b>Placa:  </b>$placa"
		echo -e "<b>Endereço IP:  </b>$(ifconfig $placa | grep 'inet' | egrep -v 'endereço|lo|inet6' | awk '{print $2}')"
		echo -e "<b>Mascara:  </b>$(ifconfig $placa | grep 'inet' | egrep -v 'endereço|lo|inet6' | awk '{print $4}')"
		echo -e ""
	done
	echo -e "<b>Gateway da Rede:  </b>$(route -n | grep 'UG[ \t]' | awk '{print $2}')"
	echo -e "\n<b>DNS Primario:  </b>$(cat /etc/resolv.conf |cut -d " " -f2| sed -n '1p')"
	echo -e "<b>DNS Secundario:  </b>$(cat /etc/resolv.conf |cut -d " " -f2| sed -n '2p')"
}

redeinfo()
{
	yad --width=320 --height=100 --undecorated --center --text "\n<b><big>\t\t   REDE</big></b>\n\n<b><big> Infomação de Rede:</big></b>\n\n$(info)" --button="Fechar!window-close:1" --image="network-wired-disconnected"
}

case $1 in

	info)
		redeinfo
	;;
	ip)
		setIp
	;;
	nome)
		setnome
	;;
	reset)
		redereset
	;;
esac
exit 0
