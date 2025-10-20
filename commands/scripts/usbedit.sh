#!/bin/bash

listusb=$(lsusb | cut -d " " -f 6-40 | grep -v "ssssLinux Foundation")
arq="/etc/udev/rules.d/70-persistent-usb.rules"
raiz="/root/.cxoffice/Aramo/dosdevices"
regedit="/root/.cxoffice/Aramo/system.reg"

validecf() {

	while :; do
		OPCAO9=$(
			yad --list \
				--title=" CONFIGURAR IMPRESSORA " --text='Tecle ESC para voltar.' \
				--width=280 --height=320 --center \
				--column='OPCAO9':NUM --column='texto':TEXT \
				--window-icon="" --no-headers --print-column=1 --separator='' --hide-column=1 \
				1 '<big>Impressora bematech</big>' \
				2 '<big>Impressoras padrao</big>' \
				3 '<big>Outras impressoras</big>'
		)
		[ $? -ne 0 ] && break
		case "$OPCAO9" in
		1)
			bemaecf
			;;
		2)
			outrosecf
			;;
		3)
			ecf
			;;
		esac
	done

}

bemaecf() {

	resetmaster kill
	#cd $raiz
	#ln -s /dev/usbEcf com20 JA ESTA NO REGEDIT
	sed -i 's/"PLATAFORMA"=*.*/"PLATAFORMA"="LINUX"/g' $regedit
	sed -i 's/"MODELO"=*.*/"MODELO"="BEMATECH"/g' $regedit
	sed -i 's/"MATRICIAL"=*.*/"MATRICIAL"="com10"/g' $regedit
	sed -i 's/"ESPACOLINHAS"=dword:000000*.*/"ESPACOLINHAS"=dword:000000"01"/g' $regedit
	lb="1"
	hexa=$(printf "%x" $lb)
	if [ $(echo $hexa | wc -c) -eq "2" ]; then
		lbpdv="0000000"$hexa
	elif [ $(echo $hexa | wc -c) -eq "3" ]; then
		lbpdv="000000"$hexa
	fi
	sed -i 's/"LINHASBUFFER"=dword:0000000*.*/"LINHASBUFFER"=dword:'"$lbpdv"'/g' $regedit
	el="8"
	hexa=$(printf "%x" $el)
	if [ $(echo $hexa | wc -c) -eq "2" ]; then
		elpdv="0000000"$hexa
	elif [ $(echo $hexa | wc -c) -eq "3" ]; then
		elpdv="000000"$hexa
	fi
	sed -i 's/"ESPACOLINHAS"=dword:0000000*.*/"ESPACOLINHAS"=dword:'"$elpdv"'/g' $regedit
	yad --title="CONFIGURAR IMPRESSORA" --text="\n\n\t<big>PDV CONFIGURADO PARA IMPRESSORA BEMATECH.</big>" --button="gtk-close:1" --center --width=500 --height=20 --image="gtk-save-as"

}

outrosecf() {

	resetmaster kill
	#cd $raiz
	#rm com20 >/dev/null 2>&1
	sed -i 's/"PLATAFORMA"=*.*/"PLATAFORMA"="LINUXARQ"/g' $regedit
	sed -i 's/"MODELO"=*.*/"MODELO"="EPSON"/g' $regedit
	sed -i 's/"MATRICIAL"=*.*/"MATRICIAL"="ESCPOS"/g' $regedit
	sed -i 's/"LINHASBUFFER"=dword:0000000*.*/"LINHASBUFFER"=dword:0000000"0"/g' $regedit
	sed -i 's/"ESPACOLINHAS"=dword:000000*.*/"ESPACOLINHAS"=dword:000000"2d"/g' $regedit
	lb="0"
	hexa=$(printf "%x" $lb)
	if [[ $(echo $hexa | wc -c) -eq "2" ]]; then
		lbpdv="0000000"$hexa
	elif [[ $(echo $hexa | wc -c) -eq "3" ]]; then
		lbpdv="000000"$hexa
	fi
	sed -i 's/"LINHASBUFFER"=dword:0000000*.*/"LINHASBUFFER"=dword:'"$lbpdv"'/g' $regedit
	el="45"
	hexa=$(printf "%x" $el)
	if [[ $(echo $hexa | wc -c) -eq "2" ]]; then
		elpdv="0000000"$hexa
	elif [[ $(echo $hexa | wc -c) -eq "3" ]]; then
		elpdv="000000"$hexa
	fi
	sed -i 's/"ESPACOLINHAS"=dword:0000000*.*/"ESPACOLINHAS"=dword:'"$elpdv"'/g' $regedit
	yad --title="CONFIGURAR IMPRESSORA" --text="\n\n\t<big>PDV CONFIGURADO PARA IMPRESSORAS PADRAO.</big>" --button="gtk-close:1" --center --width=500 --height=20 --image="gtk-save-as"

}

ecf() {
	FORM=$(yad --form --center --button="Salvar"!gtk-ok --button="gtk-cancel:1" --width=500 --title="CONFIGURAÇÃO DE IMPRESSOTA USB" --text="\n<b>Equipamentos USB localizados:</b>\n\n$listusb\n\n" --field="Novo ID " --image="gtk-connect")
	resp=$(echo "$FORM" | cut -d"|" -f 1)
	if [ ! -z $resp ]; then
		valid
		loc
		echo -e "#Impressora" >> /etc/udev/rules.d/71-persistent-usb.rules
		echo -e 'SUBSYSTEMS=="usb", ACTION=="add", DRIVERS=="?*", ATTRS{idVendor}=='"\"$V\""', ATTRS{idProduct}=='"\"$P\""', MODE=="0666", SYMLINK+="usbEcf"' >>/etc/udev/rules.d/71-persistent-usb.rules
		info
	fi
}

pin() {
	FORM=$(yad --form --center --width=500 --title="CONFIGURAÇÃO DE PINPAD USB" --text="\n<b>Equipamentos USB localizados:</b>\n\n$listusb\n\n" --field="Novo ID " --image="gtk-connect")
	resp=$(echo "$FORM" | cut -d"|" -f 1)
	if [ ! -z $resp ]; then
		valid
		loc
		echo -e "#PinPad" >> /etc/udev/rules.d/72-persistent-usb.rules
		echo -e 'SUBSYSTEMS=="usb", ACTION=="add", DRIVERS=="?*", ATTRS{idVendor}=='"\"$V\""', ATTRS{idProduct}=='"\"$P\""', MODE=="0666", SYMLINK+="usbPinPad"' >>/etc/udev/rules.d/72-persistent-usb.rules
		info
	fi
}

balanc() {
	FORM=$(yad --form --center --width=500 --title="CONFIGURAÇÃO DE BALANÇA USB" --text="\n<b>Equipamentos USB localizados:</b>\n\n$listusb\n\n" --field="Novo ID " --image="gtk-connect")
	resp=$(echo "$FORM" | cut -d"|" -f 1)
	if [ ! -z $resp ]; then
		valid
		loc
		echo -e "#Balança" >>/etc/udev/rules.d/73-persistent-usb.rules
		echo -e 'SUBSYSTEMS=="usb", ACTION=="add", DRIVERS=="?*", ATTRS{idVendor}=='"\"$V\""', ATTRS{idProduct}=='"\"$P\""', MODE=="0666", SYMLINK+="usbBal"' >>/etc/udev/rules.d/73-persistent-usb.rules
		info
	fi
}

loc() {
	V=$(echo $resp | cut -d: -f1)
	P=$(echo $resp | cut -d: -f2)
	if cat /etc/udev/rules.d/70-persistent-usb.rules | grep -q "ATTRS{idVendor}==\"$V\", ATTRS{idProduct}==\"$P\""; then
		yad --title="AVISO" --text="\n<big>Ja existe configuração para esse equipamento.\n\nValor Informado:<b> $(echo $resp)</b></big>" --button="gtk-close:1" --center --width=300 --height=100 --image="gtk-dialog-error"
		exit 1
	fi
}

info() {
	udevadm control --reload-rules
	yad --title=" " --text="\n<big>Configurado com sucesso.\n\n\n<b>Necessario reiniciar o equipamento.</b>\n\n\nValor informado:<b> $(echo $resp)</b></big>" --button="gtk-close:1" --center --width=450 --height=100 --image="gtk-save-as"
}

valid() {
	if [ ! -z $resp ]; then
		if ! echo $resp | egrep -q '^([0-9a-zA-Z]{4}[:]{1}[0-9a-zA-Z]{4})'; then
			yad --title="AVISO" --text="\n<big>ID do equipamento invalido.\n\nValor informado:<b> $(echo $resp)</b></big>" --button="gtk-close:1" --center --width=400 --height=100 --image="gtk-dialog-error"
			exit 1
		fi
	fi

}

reset() {
	yad --title="RESTAURAR CONFIGURAÇÃO USB" --center --button="Não"!gtk-cancel:1 --button="Sim"!gtk-ok:0 --text="\nDeseja <b>Restaurar</b> as configurações USB?" --image=gtk-execute --width=400 --escape-ok
	if [ $? == 0 ]; then
		setpadrao
		yad --title=" " --text="\n<b>\n\n\nRestauração realizada com sucesso.</b>" --button="gtk-close:1" --center --width=450 --image="gtk-save-as"
	fi
}

setpadrao() {

	echo -e '#############################################################################################################################' >$arq
	echo -e '#############################################            NÂO MEXER              #############################################' >>$arq
	echo -e '#############################################################################################################################' >>$arq
	echo -e '#' >>$arq
	echo -e '#Impressora' >>$arq
	echo -e 'SUBSYSTEMS=="usb", ACTION=="add", DRIVERS=="?*", ATTRS{idVendor}=="04b8", ATTRS{idProduct}=="0e03", MODE=="0666", SYMLINK+="usbEcf" #Epson' >>$arq
	echo -e 'SUBSYSTEMS=="usb", ACTION=="add", DRIVERS=="?*", ATTRS{idVendor}=="04b8", ATTRS{idProduct}=="0e27", MODE=="0666", SYMLINK+="usbEcf" #EpsonX' >>$arq
	echo -e 'SUBSYSTEMS=="usb", ACTION=="add", DRIVERS=="?*", ATTRS{idVendor}=="0b1b", ATTRS{idProduct}=="0003", MODE=="0666", SYMLINK+="usbEcf" #Bematech MP4200' >>$arq
	echo -e 'SUBSYSTEMS=="usb", ACTION=="add", DRIVERS=="?*", ATTRS{idVendor}=="20d1", ATTRS{idProduct}=="7008", MODE=="0666", SYMLINK+="usbEcf" #Elgin i9' >>$arq
	echo -e 'SUBSYSTEMS=="usb", ACTION=="add", DRIVERS=="?*", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="5720", MODE=="0666", SYMLINK+="usbEcf" #Dimep' >>$arq
	echo -e '' >>$arq
	echo -e '#PinPad' >>$arq
	echo -e 'SUBSYSTEMS=="usb", ACTION=="add", DRIVERS=="?*", ATTRS{idVendor}=="1753", ATTRS{idProduct}=="c901", MODE=="0666", SYMLINK+="usbPinPad" #GerTec 901' >>$arq
	echo -e 'SUBSYSTEMS=="usb", ACTION=="add", DRIVERS=="?*", ATTRS{idVendor}=="1753", ATTRS{idProduct}=="c902", MODE=="0666", SYMLINK+="usbPinPad" #GerTec 902' >>$arq
	echo -e 'SUBSYSTEMS=="usb", ACTION=="add", DRIVERS=="?*", ATTRS{idVendor}=="1753", ATTRS{idProduct}=="c903", MODE=="0666", SYMLINK+="usbPinPad" #GerTec 903' >>$arq
	echo -e 'SUBSYSTEMS=="usb", ACTION=="add", DRIVERS=="?*", ATTRS{idVendor}=="0b00", ATTRS{idProduct}=="3070", MODE=="0666", SYMLINK+="usbPinPad" #Igenico ipp370' >>$arq
	echo -e 'SUBSYSTEMS=="usb", ACTION=="add", DRIVERS=="?*", ATTRS{idVendor}=="079b", ATTRS{idProduct}=="0028", MODE=="0666", SYMLINK+="usbPinPad" #Igenico ipp320' >>$arq
	echo -e 'SUBSYSTEMS=="usb", ACTION=="add", DRIVERS=="?*", ATTRS{idVendor}=="11ca", ATTRS{idProduct}=="0219", MODE=="0666", SYMLINK+="usbPinPad" #Verifone' >>$arq
	echo -e '' >>$arq
	echo -e '#Balanca' >>$arq
	echo -e 'SUBSYSTEMS=="usb", ACTION=="add", DRIVERS=="?*", ATTRS{idVendor}=="1509", ATTRS{idProduct}=="2206", MODE=="0666", SYMLINK+="usbBal" #Toledo Checkout' >>$arq
	echo -e 'SUBSYSTEMS=="usb", ACTION=="add", DRIVERS=="?*", ATTRS{idVendor}=="10c4", ATTRS{idProduct}=="ea60", MODE=="0666", SYMLINK+="usbBal" #Urano Checkout' >>$arq
	echo -e 'SUBSYSTEMS=="usb", ACTION=="add", DRIVERS=="?*", ATTRS{idVendor}=="04b8", ATTRS{idProduct}=="0e03", MODE=="0666", SYMLINK+="ubsBal"' >>$arq
	rm -f /etc/udev/rules.d/71-persistent-usb.rules >/dev/null 2>&1
	rm -f /etc/udev/rules.d/72-persistent-usb.rules >/dev/null 2>&1
	rm -f /etc/udev/rules.d/73-persistent-usb.rules >/dev/null 2>&1
	
}

imp() {
	echo -e "_______________________________________" >/dev/usbEcf
	echo -e "\n\n\n****** Auto teste completado ******" >/dev/usbEcf
	echo -e "\n\n\n_______________________________________\n\n\n\n\n\n\n\n\n" >/dev/usbEcf
	yad --title="AUTO TESTE" --text="\n\n\n<b>Auto teste enviado...</b>" --button="gtk-close:1" --center --width=300 --height=50 --image="gtk-print-report"
}

case $1 in

validecf)
	validecf
	;;
pinpad)
	pin
	;;
balanca)
	balanc
	;;
reset)
	reset
	;;
imp)
	imp
	;;
padrao)
	setpadrao
	;;
esac
exit 0
