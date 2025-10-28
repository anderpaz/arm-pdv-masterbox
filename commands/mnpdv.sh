#!/bin/bash
log="/tmp/mnpdvteste.log"
regedit="/root/.cxoffice/Aramo/system.reg"
host=aramo.ddns.com.br
#host=192.168.1.244
hostInterno=192.168.1.244
ftpHost=ftp://$host
ftpHostInterno=ftp://$hostInterno
ftpUser=anderson
ftpSenha=Alfa152100
ftpander="aramo/Versao/Caixa"
ftpHomologacao="homologacao/Caixa/M5/"
ftpHomologacaomauto="homologacao/Caixa/MAuto/"
masterbox=MasterBox.zip
m5=M5.zip
mauto=MAuto.zip
isomenupdv=IsoMenuPdv.zip
clisitef=clisitef.zip
clisiteftls=clisiteftls.zip
VERDE="\033[32m"
VERMELHO="\033[31m"
NORMAL="\033[0m"
AMARELO="\033[33m"
nomepdv=$(cat /etc/hostname)
caminhomasterboxbkp="/mnt/Aramo/MASTERBOX/BKP"
caminhobkp="/mnt/Aramo/BACKUP"
data=`date +%d-%m-%Y`
datahoraminuto=`date +%d-%m-%Y-%H:%M`
controleVersao=2.0.0.5
vkernel=$(uname -r)
#MENU PRINCIPAL
##############################################################################################################
finalizar(){
	echo -e "ok" >/dev/null 2>&1
}

# testeConexao() {
# 	curl -u $ftpUser:$ftpSenha -O $ftpHost/aramo/Versao/AreaTecnica/down
# 	if [ $? -ne 0 ]; then
# 		ftpHost=$hostInterno
# 	fi
# }

tecnico() {
	while :; do
		OPCAO=$(
			yad --list \
				--title=" 	MENU ${controleVersao}" --text='Tecle ESC para voltar.' \
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
			corrigeRede
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
	corrigeRede
	from1=$(yad --center --title="CONFIGURACAO TECNICA" --text='Tecle ESC para voltar.' --form --field="":H --hide-text --entry-label "" --image="gtk-dialog-authentication")
	pass=$(echo "$from1" | cut -d"|" -f 1)
	if [[ $pass == "152100" ]]; then
		tecnico
		corrigeRede
	else
	senhaInvalida
	fi

}

senhaInstalaTLS() {

	from1=$(yad --center --title="SENHA INSTALAR TLS" --text='Tecle ESC para voltar.' --form --field="":H --hide-text --entry-label "" --image="gtk-dialog-authentication")
	pass=$(echo "$from1" | cut -d"|" -f 1)
	if [[ $pass == "136900" ]]; then
		corrigeRede
		setaTokenTefTls
	else
	senhaInvalida
	fi
}

senhaInvalida(){
	yad --title="ERRO" --text="\n\t<big>SENHA INCORRETA</big>" --button="gtk-close:1" --center --width=400 --height=100 --image="gtk-dialog-error"
}

menu() {
	# testeConexao
	while :; do
		OPCAO1=$(
			yad --list \
				--title="	MENU $controleVersao" --text='Tecle ESC para sair.' \
				--width=280 --height=320 --center \
				--column='OPCAO1':NUM --column='texto':TEXT \
				--window-icon="" --no-headers --print-column=1 --separator='' --hide-column=1 \
				101 '<big>Configuracao Tecnica</big>' \
				102 '<big>MasterBox</big>' \
				103 '<big>Status de Rede</big>' \
				104 '<big>Reiniciar PDV</big>' \
				105 '<big>Desligar PDV</big>'
				#106 '<big>Atualizar M5 Homologação </big>'\
				#107 '<big>Atualizar MAuto Homologação </big>'
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
		106)
			atualizarm5Homologacao | yad --text-info --tail --title="ATUALIZAR MASTERBOX" --width="400" --height="200" --button="gtk-close:1" --center --no-buttons --auto-close
			;;
		107)
			atualizarmautoHomologacao | yad --text-info --tail --title="ATUALIZAR MAuto" --width="400" --height="200" --button="gtk-close:1" --center --no-buttons --auto-close
			;;
		esac
	done

}

confrede() {
	while :; do
		OPCAO4=$(
			yad --list \
				--title=" CONFIGURAÇÃO DE REDE v2 " --text='Tecle ESC para voltar.' \
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
			configCaixa
			;;
		602)
			mastercp menugeral
			;;
		esac
	done
}

configCaixa() {
	while :; do
		OPCAO27=$(
			yad --list \
				--title=" CONFIGURAÇÃO MASTERBOX " --text='Tecle ESC para voltar.' \
				--width=280 --height=320 --center \
				--column='OPCAO6':NUM --column='texto':TEXT \
				--window-icon="" --no-headers --print-column=1 --separator='' --hide-column=1 \
				2701 '<big>Copiar tabela config</big>' \
				2702 '<big>Copiar tabela confignova</big>' \
				2703 '<big>Copiar as duas tabelas</big>'
		)
		[ $? -ne 0 ] && break
		case "$OPCAO27" in
		2701)
			mastercp banco
			;;
		2702)
			mastercp confignova
			;;
		2703)
			mastercp todasconfig
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
				208 '<big>Outros</big>'\
				209 '<big>Configurar banco masterbox</big>'\
				201 '<big>Configurar MasterBox.ini</big>' \
				202 '<big>Configurar Clisitef.ini</big>' \
				203 '<big>Copiar Caixa</big>' \
				207 '<big>Atualizar MasterBox</big>'\
				210 '<big>Configurar CONFITLS.ini</big>' 
		)
		[ $? -ne 0 ] && break
		case "$OPCAO2" in
		201)
			leafpad /mnt/Aramo/MASTERBOX/MasterBox.ini
			;;
		202)
			leafpad /mnt/Aramo/MASTERBOX/CliSiTef.ini
			;;
		203)
			copycaixaconfirma
			;;
		207)
			atualizar
			;;
		208)
			confmasteroutros
			;;
		209)
			configmasterpadraosistemas
			;;
		210)
			confirmaArquivoTLS
			;;
		esac
	done
}

confirmaArquivoTLS(){

		if [ ! -e "/mnt/Aramo/MASTERBOX/CONFITLS.INI" ]; then
			yad --title="ERRO" --text="\n\t<big>ARQUIVO TLS NAO EXISTE</big>" --button="gtk-close:1" --center --width=400 --height=100 --image="gtk-dialog-error"
			return 0
		fi
		leafpad /mnt/Aramo/MASTERBOX/CONFITLS.INI		
}


confmasteroutros() {
	while :; do
		OPCAO28=$(
			yad --list \
				--title=" CONF MASTERBOX OUTROS" --text='Tecle ESC para voltar.' \
				--width=280 --height=320 --center \
				--column='OPCAO2':NUM --column='texto':TEXT \
				--window-icon="" --no-headers --print-column=1 --separator='' --hide-column=1 \
				2800 '<big>Backup PDV</big>' \
				2804 '<big>Configura regedit mariadb</big>' \
				2805 '<big>Configura M5</big>' \
				2806 '<big>Configura M3</big>' 
		)
		[ $? -ne 0 ] && break
		case "$OPCAO28" in
		2800)
			backuppdv mnbackuppdv
			;;
		2804)
			confreg | yad --text-info --tail --title="CONFIGURA REGEDIT MARIADB" --width="400" --height="350" --button="gtk-close:1" --center --no-buttons --auto-close
			;;
		2805)
			confm5confirma
			;;
		2806)
			confm3confirma
			;;
		esac
	done
}

configmasterpadraosistemas() {
	while :; do
		OPCAO29=$(
			yad --list \
				--title="SELECIONE O SISTEMA" --text='Tecle ESC para voltar.' \
				--width=280 --height=320 --center \
				--column='OPCAO29':NUM --column='texto':TEXT \
				--window-icon="" --no-headers --print-column=1 --separator='' --hide-column=1 \
				2901 '<big>Config Padrão Hiper</big>'\
				2902 '<big>Config Padrão SuperBox</big>'\
				2903 '<big>Seta IP HOSTNFCE Hiper</big>'\
				2904 '<big>Seta IP HOSTNFCE SuperBox</big>'\
				2905 '<big>Configurar InfNFCe</big>'
		)
		[ $? -ne 0 ] && break
		case "$OPCAO29" in
		2901)
			setaconfigPadraoHiperConfirma
			;;
		2902)
			setaconfigPadraoSuperboxConfirma
			;;
		2903)
			configIpHipersync
			;;
		2904)
			configIpSupersync
			;;
		2905)
			menuInfInfce
			;;		
		esac
	done
}

menuInfInfce() {
	while :; do
		OPCAO30=$(
			yad --list \
				--title="SETA INFNFCE" --text='Tecle ESC para voltar.' \
				--width=280 --height=320 --center \
				--column='OPCAO30':NUM --column='texto':TEXT \
				--window-icon="" --no-headers --print-column=1 --separator='' --hide-column=1 \
				3001 '<big>Digitar Manual</big>'\
				3002 '<big>Consulta Docto Postgres</big>'\
				3003 '<big>Consulta Numnfe Firebird</big>'
				#3004 '<big>test</big>'
		)
		[ $? -ne 0 ] && break
		case "$OPCAO30" in
		3001)
			ConfiguraInfNfceConfirma
			;;
		3002)
			consultaDoctoPostgres
			;;
		3003)
			consultaDoctoFirebird
			;;
		esac
	done
}

copycaixaconfirma() {
	yad --title="COPIAR CAIXA" --center --button="CANCELAR"!gtk-cancel:1 --button="SEGUIR"!gtk-ok:0 --text="
	\nVOCÊ TEM CERTEZA QUE QUER COPIAR CAIXA?\n
	\n<span color='#ff0000'>ATENÇÃO - 
	\nESTA OPÇÃO PODE SER PREJUDICIAL!
	\nSE VOCÊ NAO SABE O QUE ESTA FAZENDO CANCELE IMEDIATAMENTE!
	</span>" --image=gtk-execute --width=400 --escape-ok
    if [ $? == 0 ]; then
        copycaixa
    fi
}

ConfiguraInfNfceConfirma() {
	yad --title="INFNFCE" --center --button="CANCELAR"!gtk-cancel:1 --button="SEGUIR"!gtk-ok:0 --text="
	\nVOCÊ TEM CERTEZA?\n
	\n<span color='#ff0000'>ATENÇÃO - 
	\nESTA OPÇÃO PODE SER PREJUDICIAL!
	\nSE VOCÊ NAO SABE O QUE ESTA FAZENDO CANCELE IMEDIATAMENTE!
	\nCONFIRA E SIGA OS PASSOS CORRERAMENTE!
	</span>" --image=gtk-execute --width=400 --escape-ok
    if [ $? == 0 ]; then
        senhaConfiguraInfNfce
    fi
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

setaconfigPadraoHiperConfirma(){

	yad --title="AVISO" --center --button="CANCELAR"!gtk-cancel:1 --button="SEGUIR"!gtk-ok:0 --text="
	\nDESEJA RECEBER UMA CONFIG PADRAO HIPER?\n
	\n<span color='#ff0000'>ATENÇÃO - 
	\nDEVE-SE UTILIZAR ESTA FUNÇÃO QUANDO O BANCO DE DADOS ESTIVER CRIADO COMPLETAMENTE...!
	</span>" --image=gtk-execute --width=400 --escape-ok
    if [ $? == 0 ]; then
        senhaconfigPadraoHiper
    fi

}

senhaConfiguraInfNfce() {

	from1=$(yad --center --title="CONFIRMA?" --text='Tecle ESC para voltar.' --form --field="":H --hide-text --entry-label "" --image="gtk-dialog-authentication")
	pass=$(echo "$from1" | cut -d"|" -f 1)
	if [[ $pass == "152100" ]]; then
	funcaoIniciasetaInfNfceManual
	else
	senhaInvalida
	fi

}

senhaconfigPadraoHiper() {

	from1=$(yad --center --title="CONFIRMA?" --text='Tecle ESC para voltar.' --form --field="":H --hide-text --entry-label "" --image="gtk-dialog-authentication")
	pass=$(echo "$from1" | cut -d"|" -f 1)
	if [[ $pass == "152100" ]]; then
		setaConfgPadraoHiper 
		resetmaster kill
	else
	senhaInvalida
	fi

}

setaconfigPadraoSuperboxConfirma(){

	yad --title="AVISO" --center --button="CANCELAR"!gtk-cancel:1 --button="SEGUIR"!gtk-ok:0 --text="
	\nDESEJA RECEBER UMA CONFIG PADRAO SUPERBOX?\n
	\n<span color='#ff0000'>ATENÇÃO - 
	\nDEVE-SE UTILIZAR ESTA FUNÇÃO QUANDO O BANCO DE DADOS ESTIVER CRIADO COMPLETAMENTE...!
	</span>" --image=gtk-execute --width=400 --escape-ok
    if [ $? == 0 ]; then
        senhaconfigPadraoSuperbox
		resetmaster kill
    fi

}

senhaconfigPadraoSuperbox() {

	from1=$(yad --center --title="CONFIRMA?" --text='Tecle ESC para voltar.' --form --field="":H --hide-text --entry-label "" --image="gtk-dialog-authentication")
	pass=$(echo "$from1" | cut -d"|" -f 1)
	if [[ $pass == "152100" ]]; then
	setaConfgPadraoSuperbox
	else
	senhaInvalida
	fi

}

cconfirmaInfNfceManual(){

	yad --title="AVISO" --center --button="NÃO"!gtk-cancel:1 --button="CONFIRMAR"!gtk-ok:0 --text="
	\nIDLOJA informado =$idlojainfnfce\n
	\nSERIE informado =$serieinfnfce\n
	\nNUMNFCE informado =$numnfceinfnfce\n
	\n<span color='#ff0000'>ATENÇÃO - 
	\nCONFIRMA?!
	</span>" --image=gtk-execute --width=400 --escape-ok
    if [ $? == 0 ]; then
        setaInfNfceInicia
		resetmaster kill
    fi

}

confirmaPathBancoFirebird(){

	yad --title="CONFIRME CAMINHO DO BANCO" --center --button="CONFIRMAR"!gtk-ok:0 --button="NÃO"!gtk-cancel:1  --text="
	\nCAMINHO PADRAO \n /banco/firebird/SUPERBOXNOVO.FDB \n
	\n<span color='#ff0000'>ATENÇÃO - 
	\nCONFIRMA?!
	</span>" --image=gtk-execute --width=400 --escape-ok
    if [ $? == 0 ]; then
	caminhodobanco=/banco/firebird/SUPERBOXNOVO.FDB
	else 
	setaPathBancoFirebird
    fi
}

confirmaPortaPostgresPadrao(){

	yad --title="CONFIRME PORTA POSTGRES" --center --button="CONFIRMAR"!gtk-ok:0 --button="NÃO"!gtk-cancel:1  --text="
	\nPORTA PADRAO POSTGRES 5432\n
	\n<span color='#ff0000'>ATENÇÃO - 
	\nCONFIRMA?!
	</span>" --image=gtk-execute --width=400 --escape-ok
    if [ $? == 0 ]; then
    echo 5432 > /tmp/portapg.porta
	portapostgres=$(tr -d '' < /tmp/portapg.porta | sed -n 1p | sed 's/ *$//g')
	else 
	setaIpPortaPostgres
    fi
}

confirmaSenhaPostgresPadrao(){

	yad --title="CONFIRME A SENHA POSTGRES" --center --button="CONFIRMAR"!gtk-ok:0 --button="NÃO"!gtk-cancel:1  --text="
	\nSENHA PADRAO POSTGRES??\n
	\n<span color='#ff0000'>ATENÇÃO - 
	\nCONFIRMA?!
	</span>" --image=gtk-execute --width=400 --escape-ok
    if [ $? == 0 ]; then
	echo pg29766* > /tmp/senhapg.senha
	else 
	setaSenhaPostgres
    fi
}	

setaIpServidorPostgres(){
	FORMIPPOSTGRES=$(yad --form --center --button="gtk-cancel:1"  --button="Salvar"!gtk-ok --width=500 --title="IP DO POSTGRES" --text="\n\t<b>IP onde esta o postgres:</b>\t<b>Ex: 192.168.1.200</b>\n\n" --field="" --image="network-wired-disconnected")
	ippostgres=$(echo "$FORMIPPOSTGRES" | cut -d "|" -f 1)
	validaIdsInformados ippostgres $ippostgres
}

setaIpServidorFirebird(){
	FORMIPFIREBIRD=$(yad --form --center --button="gtk-cancel:1"  --button="Salvar"!gtk-ok --width=500 --title="IP SERVIDOR FIREBIRD" --text="\n\t<b>IP onde esta o firebird:</b>\t<b>Ex: 192.168.1.200</b>\n\n" --field="" --image="network-wired-disconnected")
	ipfirebird=$(echo "$FORMIPFIREBIRD" | cut -d "|" -f 1)
	validaIdsInformados ipfirebird $ipfirebird
}

setaIpPortaPostgres(){
	FORMPORTAPOSTGRES=$(yad --form --center --button="gtk-cancel:1"  --button="Salvar"!gtk-ok --width=500 --title="PORTA DO POSTGRES" --text="\n\t<b>Porta onde esta o postgres:</b>\t<b>Ex:5432</b>\n\n" --field="" --image="network-wired-disconnected")
	portapg=$(echo "$FORMPORTAPOSTGRES" | cut -d "|" -f 1)
	echo $portapg > /tmp/portapg.porta
	portapostgres=$(tr -d '' < /tmp/portapg.porta | sed -n 1p | sed 's/ *$//g')
	validaIdsInformados portapostgres $portapostgres
}
setaSenhaPostgres(){
	FORMSENHAPOSTGRES=$(yad --form --center --button="gtk-cancel:1"  --button="Salvar"!gtk-ok --width=500 --title="SENHA DO POSTGRES" --text="\n\t<b>Senha do postgres:</b>\t<b>Digite a senha.</b>\n\n" --field="":H --image="gtk-dialog-authentication")
	senhapostgres=$(echo $FORMSENHAPOSTGRES | cut -d "|" -f 1)
	echo $senhapostgres > /tmp/senhapg.senha
}

setaIdlojaInfNfce(){
	idlojaexemplos=1,2,98,100
	idlojaexemploh=001,002,098,100
	FORMINFIFLOJA=$(yad --form --center --button="gtk-cancel:1"  --button="Salvar"!gtk-ok --width=500 --title="INFORME O IDLOJA" --text="\n\t<b>Ex: Hiper $idlojaexemploh </b>\t<b>Ex: SuperBox $idlojaexemplos INFORME O IDLOJA </b>\n\n" --field="" --image="system")
	idlojainfnfce=$(echo "$FORMINFIFLOJA" | cut -d "|" -f 1)
	validaIdsInformados idloja $idlojainfnfce
}

setaSerieInfNfce(){
	serieexemplos=1,2,98,100
	serieexemploh=001,002,098,100
	FORMINFSERIE=$(yad --form --center --button="gtk-cancel:1"  --button="Salvar"!gtk-ok --width=500 --title="INFORME A SERIE" --text="\n\t<b>Ex: Hiper $serieexemploh </b>\t<b>Ex: SuperBox $serieexemplos INFORME A SERIE </b>\n\n" --field="" --image="system")
	serieinfnfce=$(echo "$FORMINFSERIE" | cut -d "|" -f 1)
	validaIdsInformados serie $serieinfnfce
}

setaNumNfceInfNfce(){
	FORMNUMNFCE=$(yad --form --center --button="gtk-cancel:1"  --button="Salvar"!gtk-ok --width=500 --title="INFORME O NUMERO NFCE (DOCTO)" --text="\n\t<b>INFORME NUMERO NFCE (DOCTO) :</b>\t<b> ATENÇÃO!!!</b>\n\n" --field="" --image="system")
	numnfceinfnfce=$(echo "$FORMNUMNFCE" | cut -d "|" -f 1)
	validaIdsInformados infNfce $numnfceinfnfce
}

setaPathBancoFirebird(){
	FORMPATHBANCOFIREBIRD=$(yad --form --center --button="gtk-cancel:1"  --button="Salvar"!gtk-ok --width=500 --title="PATH BANCO" --text="\n\t<b>Caminho do banco:</b>\t<b>Ex: \n C:/banco/firebird/SUPERBOXNOVO.FDB</b>\n\n" --field="" --image="network-wired-disconnected")
	pathbanco=$(echo "$FORMPATHBANCOFIREBIRD" | cut -d "|" -f 1)
	echo $pathbanco > /tmp/pathbancofirebird.banco
	caminhodobanco=$(tr -d '' < /tmp/pathbancofirebird.banco | sed -n 1p | sed 's/ *$//g')
}

setaTokenTefTls(){
	tokenRegistroTLS=$(yad --form --center --button="gtk-cancel:1"  --button="Salvar"!gtk-ok --width=500 --title="Informe o TokenRegistro" --text="\n\t<b>TokenRegistroTLS do cliente.</b>\t<b>Ex:1234-1234-1234-1234</b>\n\n" --field="" --image="network-wired-disconnected")
	tokenRegistroTLSValido=$(echo "$tokenRegistroTLS" | cut -d "|" -f 1)
	validaIdsInformados TokenRegistroTLSValido $TokenRegistroTLSValido
}

validaIdsInformados(){
	case $1 in
		TokenRegistroTLSValido)
			if ! echo $tokenRegistroTLSValido |egrep -q '^([0-9]{1,4}[-]){3}[0-9]{1,4}$'; then
			yad --title="ERRO" --text="\n\t<big>INFORMACOES INCORRETAS.\n\nVALOR INFORMADO:<b> $(echo "$tokenRegistroTLSValido" | cut -d "|" -f 1)</b></big>" --button="gtk-close:1" --center --width=400 --height=100 --image="gtk-dialog-error"
			manutmaster
			exit 0
			fi
			iniciaInstalaTefTLS $tokenRegistroTLSValido | yad --text-info --tail --title="INSTALACAO TLS" --width="370" --height="200" --button="gtk-close:1" --center --no-buttons --auto-close
		;;
		ippostgres)
			if ! echo $ippostgres |egrep -q '^(([0-9]{1,2}|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.){3}([0-9]{1,2}|1[0-9][0-9]|2[0-4][0-9]|25[0-4])$'; then
			yad --title="ERRO" --text="\n\t<big>Endereço IP informado é invalido.\n\nValor informado:<b> $(echo $ippostgres)</b></big>" --button="gtk-close:1" --center --width=400 --height=100 --image="gtk-dialog-error"
			menuInfInfce
			exit 0
			fi
		;;
		ipfirebird)
			if ! echo $ipfirebird |egrep -q '^(([0-9]{1,2}|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.){3}([0-9]{1,2}|1[0-9][0-9]|2[0-4][0-9]|25[0-4])$'; then
			yad --title="ERRO" --text="\n\t<big>Endereço IP informado é invalido.\n\nValor informado:<b> $(echo $ipfirebird)</b></big>" --button="gtk-close:1" --center --width=400 --height=100 --image="gtk-dialog-error"
			menuInfInfce
			exit 0
			fi
		;;
		portapostgres)
			if ! echo $portapostgres |egrep -q '^([0-9]|[0-9][0-9]|[0-9][0-9][0-9])+$'; then
			yad --title="ERRO" --text="\n\t<big>Porta informada é invalida.\n\nValor informado:<b> $(echo $portapostgres)</b></big>" --button="gtk-close:1" --center --width=400 --height=100 --image="gtk-dialog-error"
			menuInfInfce
			exit 0
			fi
		;;
		idloja)

			if ! echo $2 |egrep -q '^([1-9]|[1-9][0-9]|[0-9][0-9][0-9])$'; then
				yad --title="ERRO" --text="\n\t<big>IDLOJA invalida!.\n\nIDLOJA informado:<b> $(echo $2)</b></big>" --button="gtk-close:1" --center --width=400 --height=100 --image="gtk-dialog-error"
				menuInfInfce
			fi
			
		;;
		serie)
			if ! echo $2 |egrep -q '^([0-9]|[0-9][0-9]|[0-8][0-9][0-9])$'; then
				yad --title="ERRO" --text="\n\t<big>SERIE invalida.\n\nNUM SERIE informado:<b> $(echo $2)</b></big>" --button="gtk-close:1" --center --width=400 --height=100 --image="gtk-dialog-error"
				menuInfInfce
				exit 0
			fi
			
		;;
		infNfce)
			if ! echo $2 |egrep -q '^[0-9]|[0-9]([1-9])?$'; then
				yad --title="ERRO" --text="\n\t<big>NUMNFCE invalido.\n\nNUMNFCE informado:<b> $(echo $2)</b></big>" --button="gtk-close:1" --center --width=400 --height=100 --image="gtk-dialog-error"
				menuInfInfce
				exit 0
			fi
		;;
		verdocto)
			docto=$(tr -d '' < $caminhobkp/SQL/lctoprodutos_pdv.$data.consulta | sed -n 3p | sed 's/ *$//g')
			if ! echo ${docto} |egrep -q '^([1-9]|[1-9][0-9]|[1-8][0-8][0-9])+$'; then
				yad --title="ERRO" --text="\n\t<big>NÃO FOI POSSIVEL FAZER CONSULTA NO POSTGRES.\n\nVERIFIQUE OS DADOS DIGITADOS. :<b> $(echo ${docto})</b></big>" --button="gtk-close:1" --center --width=400 --height=100 --image="gtk-dialog-error"
				mv $caminhobkp/SQL/lctoprodutos_pdv.$data.sql $caminhobkp/SQL/old/ERR_CONSULTA_lctoprodutos_pdv.$datahoraminuto.sql
				menuInfInfce
				exit 0
			fi
		;;
		vernumnfce)
			numnfce=$(tr -d '' < $caminhobkp/SQL/pdv.numnfce.$data.consulta | sed -n 4p | sed 's/ *$//g')
			if ! echo ${numnfce} |egrep -q '^([1-9]|[1-9][0-9]|[1-8][0-8][0-9])+$'; then
				yad --title="ERRO" --text="\n\t<big>NÃO FOI POSSIVEL FAZER CONSULTA NO FIREBIRD.\n\nVERIFIQUE OS DADOS DIGITADOS. :<b> $(echo ${docto})</b></big>" --button="gtk-close:1" --center --width=400 --height=100 --image="gtk-dialog-error"
				mv $caminhobkp/SQL/pdv.numnfce.$data.consulta $caminhobkp/SQL/old/ERR_CONSULTA_firebird_pdv_numnfce.$datahoraminuto.sql
				rm /tmp/consulta.firebird.sql
				menuInfInfce
				exit 0
			fi
	esac
}

setaInfNfceIniciaPostgres(){
		setaInfNfceConsultaPostgres | yad --text-info --tail --title="UPDATE INFNFCE" --width="400" --height="350" --button="gtk-close:1" --center --no-buttons --auto-close
}

setaInfNfceIniciaFirebird(){
		setaInfNfceConsultaFirebird | yad --text-info --tail --title="UPDATE INFNFCE" --width="400" --height="350" --button="gtk-close:1" --center --no-buttons --auto-close
}

funcaoIniciasetaInfNfceManual(){
	setaIdlojaInfNfce
	setaSerieInfNfce
	setaNumNfceInfNfce
	cconfirmaInfNfceManual
	
}
consultaDoctoPostgres(){
	backuppdv VerificaCaminhoBkp
	setaIpServidorPostgres
	setaIdlojaInfNfce
	setaSerieInfNfce
	confirmaPortaPostgresPadrao
	confirmaSenhaPostgresPadrao
	testaPacotePostgres
	mastersql ConsultaDoctoPostgres $idlojainfnfce $serieinfnfce $ippostgres $portapostgres
	validaIdsInformados verdocto
	setaInfNfceIniciaPostgres
	# setaInfNfceIniciaPostgres
}

consultaDoctoFirebird(){
	backuppdv VerificaCaminhoBkp
	setaIpServidorFirebird
	setaIdlojaInfNfce
	setaSerieInfNfce
	confirmaPathBancoFirebird
	testaPacoteFirebird
	mastersql ConsultaNumnfceFirebird $idlojainfnfce $serieinfnfce $ipfirebird $caminhodobanco
	validaIdsInformados vernumnfce
	setaInfNfceIniciaFirebird
	rm /tmp/pathbancofirebird.banco
}

setaInfNfceConsultaPostgres(){
	
	echo "--> BANCO DE DADOS POSTGRES. <--"
	echo
	resetmaster kill
	echo "--> OK!. AGUARDE... <--"
	sleep 1
	echo
	echo "--> VERIFICANDO DEPENDENCIAS...<--"
	echo
	echo "--> IP POSTGRES INFORMADO ="$ippostgres" <--"
	echo
	echo "--> IDLOJA INFORMADO ="$idlojainfnfce" <--"
	echo
	echo "--> SERIE INFORMADA ="$serieinfnfce" <--"
	echo
	echo "--> PORTA INFORMADA ="$portapostgres
	echo
	echo "--> OK!. AGUARDE... <--"
	echo
	echo "--> NUMNFCE LOCALIZADO ="${docto}" <--"
	fazBkpInfnfce
	echo	
	mastersql UpdateInfNfceConsultaPostgres $idlojainfnfce $serieinfnfce $ippostgres $portapostgres
	sleep 2
	echo "--> OK!. <--"
	echo
	echo "--> FAÇA OS TESTE E VERIFIQUE OS DADOS!! <--"
	echo "--> TECLA ESC PARA CONTINUAR. <--"
	exit 0
 	
}

setaInfNfceConsultaFirebird(){
	
	echo "--> BANCO DE DADOS FIREBIRD. <--"
	echo
	resetmaster kill
	echo "--> OK!. AGUARDE... <--"
	sleep 1
	echo
	echo "--> VERIFICANDO DEPENDENCIAS...<--"
	echo
	echo "--> IP FIREBIRD INFORMADO ="$ipfirebird" <--"
	echo
	echo "--> IDLOJA INFORMADO ="$idlojainfnfce" <--"
	echo
	echo "--> SERIE INFORMADA ="$serieinfnfce" <--"
	echo
	echo "--> OK!. AGUARDE... <--"
	echo
	echo "--> NUMNFCE LOCALIZADO ="${numnfce}" <--"
	fazBkpInfnfce
	echo	
	mastersql UpdateInfNfceConsultaFirebird $idlojainfnfce $serieinfnfce $ippostgres
	sleep 2
	echo "--> OK!. <--"
	echo
	echo "--> FAÇA OS TESTE E VERIFIQUE OS DADOS!! <--"
	echo "--> TECLA ESC PARA CONTINUAR. <--"
	exit 0
 	
}

testaPacoteFirebird(){
	se_repo=$(apt-cache search firebird3.0-utils | grep ^"firebird3.0-utils")
	if [ -n "$se_repo" ]
	then
	echo "pacote $se_repo existe nos repositorios segue o baile."
	else
	downPacoteFirebirdProgress
	fi
}

testaPacotePostgres(){
	se_repo=$(apt-cache search postgresql-client-9.6 | grep ^"postgresql-client-9.6")
	if [ -n "$se_repo" ]
	then
	echo "pacote $se_repo existe nos repositorios segue o baile."
	else
	downPacotePostgresProgress
	fi

}

downPacoteFirebirdProgress(){
IniciaDownPacoteFirebird | yad --undecorated --borders=15 --progress --pulsate --percentage=85 --width=300 --text="<b>\tBaixando e instalando dependencias aguarde...</b>" --progress-text="Aguarde ..." --auto-close --auto-kill --center --no-buttons --height=80 --image="gtk-save-as"
}

downPacotePostgresProgress(){
IniciaDownPacotePostgres | yad --undecorated --borders=15 --progress --pulsate --percentage=85 --width=300 --text="<b>\tBaixando e instalando dependencias aguarde...</b>" --progress-text="Aguarde ..." --auto-close --auto-kill --center --no-buttons --height=80 --image="gtk-save-as"
}

IniciaDownPacoteFirebird(){
	downSourceList
	downPacoteFirebird
}

IniciaDownPacotePostgres(){
	downSourceList
	downPacotePostgres
}

downSourceList(){
	echo "Realizando download aramo.list"
	cd /tmp/
	curl -u $ftpUser:$ftpSenha -O $ftpHost/$ftpander/aramo.list
		if [[ $? -ne 0 ]]; then
			echo "Erro ao realizar download aramo.list"
			echo
			echo " -->ERRO... <--"
			echo
			echo " --> ESC PARA CONTINUAR. <--"
			exit 0
		else
		echo "OK!"
		fi
	echo
	echo "--> BAIXOU aramo.list COM SUCESSO. <--"
}

downPacotePostgres(){
	echo "baixando e instalando aguarde..."
	cp aramo.list /etc/apt/sources.list.d/
	apt-get update	
	echo "Aguarde instalando postgresql client"
	apt-get install postgresql-client-9.6 -y
	rm /etc/apt/sources.list.d/aramo.list
}

downPacoteFirebird(){
	echo "baixando e instalando aguarde..."
	cp aramo.list /etc/apt/sources.list.d/
	apt-get update	
	echo "Aguarde instalando firebird3.0-utils"
	apt-get install firebird3.0-utils -y
	rm /etc/apt/sources.list.d/aramo.list
}

fazBkpInfnfce(){
	backuppdv VerificaCaminhoBkp
	mastersql FazBackupInfNfce
}

setaInfNfceInicia(){
		setaInfNfce | yad --text-info --tail --title="UPDATE INFNFCE" --width="400" --height="350" --button="gtk-close:1" --center --no-buttons --auto-close
}

setaInfNfce(){
	resetmaster kill
	echo "--> IDLOJA INFORMADO = $idlojainfnfce <--"
	echo 
	echo "--> SERIE INFORMADO = $serieinfnfce <--"
	echo
	echo "--> NUMERO NFCE INFORMADO = $numnfceinfnfce <--"
	echo
	sleep 2
	echo "--> FAZENDO BACKUP INFNFCE DADOS ANTIGOS <--"
	echo
	echo "--> /mnt/Aramo/BACKUP/SQL/ <--"
	echo
	fazBkpInfnfce
	echo "--> OK <--"
	echo
	echo "--> FAZENDO UPDATE INFNFCE <--"
	echo
	mastersql SetInfNFCesql $idlojainfnfce $serieinfnfce $numnfceinfnfce
	sleep 2
	echo "--> IDLOJA =$idlojainfnfce, SERIE =$serieinfnfce, NUMNFCE =$numnfceinfnfce <--"
	echo
	echo "--> OK <--"
	echo
	echo "--> TECLA ESC PARA CONTINUAR. <--"
	break
	exit 0
}

configIpHipersync(){
	ipexemploh=192.168.1.200
	FORM=$(yad --form --center --button="gtk-cancel:1"  --button="Salvar"!gtk-ok --width=500 --title="SETA IP SERVIDOR" --text="\n\t<b>IP DO SERVIDOR ONDE ESTA O HIPERSYNC:</b>\t<b>Ex: $ipexemploh</b>\n\n" --field="" --image="system")
	ip=$(echo "$FORM" | cut -d "|" -f 1)
	if [ -z $ip ];then
		finalizar
		exit 1
	fi
	setaipConfigHipersync
}

configIpSupersync(){
	ipexemplos=192.168.1.200
	FORM=$(yad --form --center --button="gtk-cancel:1"  --button="Salvar"!gtk-ok --width=500 --title="SETA IP SERVIDOR" --text="\n\t<b>IP DO SERVIDOR ONDE ESTA O SUPERSYNC:</b>\t<b>Ex: $ipexemplos</b>\n\n" --field="" --image="system")
	ip=$(echo "$FORM" | cut -d "|" -f 1)
	if [ -z $ip ];then
		finalizar
		exit 1
	fi
	setaipConfigSupersync
}

# ValidaconfigIpHipersync(){
# 	if ! echo $ip |egrep -q '^(([0-9]{1,2}|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.){3}([0-9]{1,2}|1[0-9][0-9]|2[0-4][0-9]|25[0-4])$'; then
# 		yad --title="ERRO" --text="\n\t<big>Endereço IP informado é invalido.\n\nValor informado:<b> $(echo $ip)</b></big>" --button="gtk-close:1" --center --width=400 --height=100 --image="gtk-dialog-error"
# 		finalizar
# 		exit 1
# 	fi
# 	ping -c 2 -w 4 $ip >> $log 2>&1
# 	if [ ! $? -eq 0 ]; then
# 		yad --title="ERRO" --text="\n\t<big>Host de destino inacessivel.\n\nValor informado:<b> $(echo $ip)</b></big>" --button="gtk-close:1" --center --width=400 --height=100 --image="gtk-dialog-error"
# 		finalizar
# 		exit 1
# 	fi
# }

# ValidaconfigIpSupersync(){
# 	if ! echo $ip |egrep -q '^(([0-9]{1,2}|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.){3}([0-9]{1,2}|1[0-9][0-9]|2[0-4][0-9]|25[0-4])$'; then
# 		yad --title="ERRO" --text="\n\t<big>Endereço IP informado é invalido.\n\nValor informado:<b> $(echo $ip)</b></big>" --button="gtk-close:1" --center --width=400 --height=100 --image="gtk-dialog-error"
# 		finalizar
# 		exit 1
# 	fi
# 	ping -c 2 -w 4 $ip >> $log 2>&1
# 	if [ ! $? -eq 0 ]; then
# 		yad --title="ERRO" --text="\n\t<big>Host de destino inacessivel.\n\nValor informado:<b> $(echo $ip)</b></big>" --button="gtk-close:1" --center --width=400 --height=100 --image="gtk-dialog-error"
# 		finalizar
# 		exit 1
# 	fi
# }

setaipConfigHipersync(){
		ipConfigHipersync | yad --text-info --tail --title="ALTERANDO CONFIG HOSTNFCE" --width="320" --height="180" --button="gtk-close:1" --center --no-buttons --auto-close
}

setaipConfigSupersync(){
		ipConfigSupersync | yad --text-info --tail --title="ALTERANDO CONFIG HOSTNFCE" --width="320" --height="180" --button="gtk-close:1" --center --no-buttons --auto-close
}

ipConfigHipersync(){
	echo "--> INFORME O IP DO HIPERSYNC. <--"
	echo "--> OK <--" 
	echo 
	# echo "--> VERIFICANDO SE O IP É VALIDO... <--"
	# ValidaconfigIpHipersync
	# echo "--> OK <--"
	# echo
	echo "--> FAZENDO UPDATE CONFIG HOSTNFCE <--"
	mastersql SetHostNfceHiper $ip
	echo
	echo "--> OK <--"
	echo "--> TECLA ESC PARA CONTINUAR. <--"
	resetmaster kill
	exit 0
}

ipConfigSupersync(){
	echo "--> INFORME O IP DO SUPERSYNC. <--"
	echo "--> OK <--" 
	echo 
	echo "--> VERIFICANDO SE O IP É VALIDO... <--"
	# ValidaconfigIpSupersync
	echo "--> OK <--"
	echo
	echo "--> FAZENDO UPDATE CONFIG HOSTNFCE <--"
	mastersql SetHostNfceSuperbox $ip
	echo
	echo "--> OK <--"
	echo "--> TECLA ESC PARA CONTINUAR. <--"
	resetmaster kill
	exit 0
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
				1001 '<big>Atualizar M3</big>' \
				1002 '<big>Atualizar CliSitef</big>'\
				1003 '<big>Atualizar IsoMenuPdv</big>'
				# 1005 '<big>Atualizar CliSitef TLS</big>'\
				# 1004 '<big>Atualizar M5 Homologacao</big>'
		)
		[ $? -ne 0 ] && break
		case "$OPCAO10" in
		1000)
			atualizarm5 | yad --text-info --tail --title="ATUALIZAR MASTERBOX" --width="400" --height="200" --button="gtk-close:1" --center --no-buttons --auto-close
			;;
		1001)
			atualizarm3 | yad --text-info --tail --title="ATUALIZAR MASTERBOX" --width="400" --height="200" --button="gtk-close:1" --center --no-buttons --auto-close
			;;
		1002)
			atualizarclisitef | yad --text-info --tail --title="ATUALIZAR CLISITEF" --width="400" --height="200" --button="gtk-close:1" --center --no-buttons --auto-close
			;;
		1003)
			isomenupdvconfirma
			;;
		1004)
		atualizarm5Homologacao | yad --text-info --tail --title="ATUALIZAR MASTERBOX" --width="400" --height="200" --button="gtk-close:1" --center --no-buttons --auto-close
		esac
	done

}

isomenupdvconfirma(){
	yad --title="ATUALIZA ISO MENU PDV" --center --button="CANCELAR"!gtk-cancel:1 --button="SEGUIR"!gtk-ok:0 --text="
	\n<span color='#ff0000'>ATUALIZAR ISO MENU PDV?\n
	</span>" --image=gtk-execute --width=400 --escape-ok
    if [ $? == 0 ]; then
        setdownisomenupdv
    fi
}

setdownisomenupdv(){

	downisomenupdv | yad --text-info --tail --title="ATUALIZA ISO MENU PDV" --width="370" --height="200" --button="gtk-close:1" --center --no-buttons --auto-close
}

downisomenupdv(){

	cd /tmp/
	echo
	echo "Realizando download Iso Menu Pdv"
	curl -u $ftpUser:$ftpSenha -O $ftpHost/$ftpander/IsoMenuPdvM5/$isomenupdv
		if [[ $? -ne 0 ]]; then
			echo "Erro ao realizar download"
			echo
			echo " -->ERRO... <--"
			echo
			echo " --> ESC PARA CONTINUAR. <--"
			exit 0
		else
		echo "OK!"
		fi
	echo
	echo "Atualizando Iso Menu Pdv  "
	unzip -o $isomenupdv -d isomenupdv >/dev/nulll 2>&1
	rm $isomenupdv -f
	chmod 777 isomenupdv/*
	mv isomenupdv/* /usr/bin/ -f
	echo "OK!"
	echo
	echo " --> ATUALIZACAO REALIZADA COM SUCESSO. <--"
	echo
	echo " --> ESC PARA CONTINUAR. <--"
	break
}

confirmaAtualizarClisitef(){
	yad --title="ATUALIZAR CLISITEF" --center --button="NAO"!gtk-cancel:1 --button="SIM"!gtk-ok:0 --text="
	\n<span color='#ff0000'>GOSTARIA DE ATUALIZAR A CLISITEF?\n
	</span>" --image=gtk-execute --width=400 --escape-ok
    if [ $? == 0 ]; then
        atualizarclisitef
    fi
}

atualizarclisitef() {

	# if [[ -e /mnt/Aramo/MASTERBOX/CONFITLS.INI ]]; then
	# 	echo " --> ERRO! <--"
	# 	echo
	# 	echo " --> AVISO ! EXISTE ARQUIVO CONFITLS.INI <--"
	# 	echo
	# 	echo " --> /mnt/Aramo/MASTERBOX/CONFITLS.INI <--"
	# 	echo
	# 	echo " --> NAO É POSSIVEL BAIXAR CLISITEF PADRÃO <--"
	# 	echo
	# 	echo " --> UTILIZE ATUALIZAR CLISITEFTLS <--"
    # 	echo
    # 	echo " --> ESC PARA CONTINUAR. <--"
	# 	yad --title="ERRO" --text="\n\t<big>ERRO.\n\n" --button="gtk-close:1" --center --width=400 --height=100 --image="gtk-dialog-error"
	# else
	cd /tmp/
	echo
	echo "Realizando download do CliSitef"
	curl -u $ftpUser:$ftpSenha -O $ftpHost/$ftpander/Clisitef/$clisitef
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
	echo "Atualizando CliSitef"
	cp $clisitef /mnt/Aramo/MASTERBOX/
	cd /mnt/Aramo/MASTERBOX/
	unzip -o $clisitef >/dev/null 2>&1
	rm $clisitef -f
	echo "OK!"
	echo
	echo " --> ATUALIZACAO REALIZADA COM SUCESSO. <--"
	echo
	echo " --> ESC PARA CONTINUAR. <--"
}

# atualizarclisiteftls(){
# 	if [[ -e /mnt/Aramo/MASTERBOX/CONFITLS.INI ]]; then
# 		cd /tmp/
# 	echo
# 	echo "Realizando download do CliSitefTLS"
# 	curl -u $ftpUser:$ftpSenha -O $ftpHost/$ftpander/Clisitef/$clisiteftls
# 		if [[ $? -ne 0 ]]; then
# 			echo "Erro ao realizar download"
# 			echo
# 			echo " --> ATUALIZACAO NAO REALIZADA. <--"
# 			echo
# 			echo " --> ESC PARA CONTINUAR. <--"
# 			exit 0
# 		else
# 		echo "OK!"
# 		fi
# 	echo
# 	echo "Atualizando CliSitef TLS"
# 	cp $clisiteftls /mnt/Aramo/MASTERBOX/
# 	cd /mnt/Aramo/MASTERBOX/
# 	unzip -o $clisiteftls >/dev/null 2>&1
# 	rm $clisiteftls -f
# 	echo "OK!"
# 	echo
# 	echo " --> ATUALIZACAO REALIZADA COM SUCESSO. <--"
# 	echo
# 	echo " --> ESC PARA CONTINUAR. <--"
# 	else
	
# 		echo " --> ERRO! <--"
# 		echo
# 		echo " --> AVISO ! NÃO EXISTE ARQUIVO CONFITLS.INI <--"
# 		echo
# 		echo " --> /mnt/Aramo/MASTERBOX/CONFITLS.INI <--"
# 		echo
# 		echo " --> NAO É POSSIVEL BAIXAR CLISITEFTLS <--"
# 		echo
# 		echo " --> UTILIZE ATUALIZAR CLISITEF <--"
#     	echo
#     	echo " --> ESC PARA CONTINUAR. <--"
	
# 	fi

# }

iniciaInstalaTefTLS(){
	echo " --> OK <--"
	echo
	sleep 2
	arqtls="/mnt/Aramo/MASTERBOX/CONFITLS.INI"
	echo " --> CRIANDO ARQUIVO CONFITLS.INI AGUARDE... <--"
	sleep 1
	cat > $arqtls << EOF
[ConfiguracaoTLS]
TipoComunicacaoExterna=TLSGWP
URLTLS=tls-prod.fiservapp.com
TokenRegistro=$1
EOF
	echo
	echo " --> OK ARQUIVO CRIADO <--"
	echo
	confirmaAtualizarClisitef
	echo
	echo " --> AGUARDE... <--"
	echo
	echo " --> OK... <--"
	echo
	echo " --> ESC PARA CONTINUAR. <--"
}

atualizarm3() {

	if [[ -e /etc/setm3 ]]; then
		cd /tmp/
		echo
		echo "Realizando download do MasterBox"
		curl -u $ftpUser:$ftpSenha -O $ftpHost/$ftpander/M3/$masterbox
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
		curl -u $ftpUser:$ftpSenha -O $ftpHost/$ftpander/M5/$m5			
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

atualizarm5Homologacao() {
	if [[ -e /etc/setm5 ]]; then
		cd /tmp/
		echo
		echo "Realizando download do MasterBox"
		curl -u $ftpUser:$ftpSenha -O $ftpHostInterno/$ftpHomologacao/$m5			
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
		resetmaster kill
		unzip -o $m5 >/dev/null 2>&1
		mv MasterBox.exe MasterBox.exe.old
		mv M5.exe MasterBox.exe
		rm $m5 -f
		cp /tmp/libmariadb.dll /mnt/Aramo/MASTERBOX/
		echo "OK!"
		echo
		echo " --> ATUALIZACAO REALIZADA COM SUCESSO. <--"
    	echo " --> AVISO VOCE BAIXOU VERSAO DA HOMOLOGAÇÃO!!! <--"
		echo
    	echo " --> ESC PARA CONTINUAR. <--"
		resetmaster
		exit 0
		
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

atualizarmautoHomologacao() {
	if [[ -e /etc/setm5 ]]; then
		cd /tmp/
		echo
		echo "Realizando download do MasterBox"
		curl -u $ftpUser:$ftpSenha -O $ftpHostInterno/$ftpHomologacaomauto/$mauto			
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
		cp $mauto /mnt/Aramo/MASTERBOX/
		cd /mnt/Aramo/MASTERBOX/
		
		resetmaster kill
		unzip -o $mauto >/dev/null 2>&1
		mv MasterBox.exe MasterBox.exe.old
		mv MAuto.exe MasterBox.exe
		rm $mauto -f
		echo "OK!"
		echo
		echo " --> ATUALIZACAO REALIZADA COM SUCESSO. <--"
    	echo " --> AVISO VOCE BAIXOU VERSAO DA HOMOLOGAÇÃO!!! <--"
		echo
    	echo " --> ESC PARA CONTINUAR. <--"
		resetmaster
		exit 0
		
		
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
	chmod +x /opt/cxoffice/bin/cxreboot
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

manutmaster(){
		while :; do
			OPCAO5=$(
				yad --list \
				--title=" MANUTENÇÃO MASTERBOX " --text='Tecle ESC para voltar.' \
				--width=280 --height=320 --center \
				--column='OPCAO5':NUM --column='texto':TEXT \
				--window-icon="" --no-headers --print-column=1 --separator='' --hide-column=1 \
				500 '<big>Finalizar MasterBox</big>' \
				501 '<big>Log atual do MasterBox</big>'\
				502 '<big>Verifica Espaço em Disco</big>'\
				503 '<big>Backup</big>'\
				504 '<big>Biometria</big>'\
				506 '<big>Instalar TEF TLS</big>')
				#506 '<big>Display</big>')
		[ $? -ne 0 ] && break
		case "$OPCAO5" in
		500)
			resetmaster kill
			;;
		501)
			leafpad /mnt/Aramo/MASTERBOX/LOG/MASTERBOX_$(date "+%Y%m%d").log
			;;
		502)
			hdsetaverificaespaco
			;;
		503)
			ManuMasterBkp
			;;
		504)
			MenuBiometria
			;;
		506)
			senhaInstalaTLS
			;;
		507)

			;;
		esac
	done
}

MenuBiometria(){
		while :; do
			OPCAO5=$(
				yad --list \
				--title=" BIOMETRIA " --text='Tecle ESC para voltar.' \
				--width=280 --height=320 --center \
				--column='OPCAO5':NUM --column='texto':TEXT \
				--window-icon="" --no-headers --print-column=1 --separator='' --hide-column=1 \
				504 '<big>Instalar Control ID</big>'\
				505 '<big>Instalar Nitgen</big>'\
				506 '<big>Instalar NitgenHFDU06R</big>')
		[ $? -ne 0 ] && break
		case "$OPCAO5" in
		504)
			MenuDependenciaControlid
			;;
		505)
			ValidaKernel
			;;
		506)
			ValidaKernelHFDU06R
			;;
		esac
	done
}

corrigeRede(){
	systemctl disable wicd
	systemctl stop wicd
}

ValidaKernelHFDU06R(){
		if ! echo $vkernel |egrep -q '6.1.0-40-amd64'; then
			yad --title="ERRO" --text="\n\t<big>KERNEL INVALIDO\n\nPrecisa que seja 6.1.0-40-amd64 e sua versao atual é:<b> $(echo $vkernel)</b></big>" --button="gtk-close:1" --center --width=400 --height=100 --image="gtk-dialog-error"
			exit 0
		fi
		MenuDependenciaNitgenHFDU06R
}

ValidaKernel(){
		if ! echo $vkernel |egrep -q '6.1.0-40-amd64'; then
			yad --title="ERRO" --text="\n\t<big>KERNEL INVALIDO\n\nPrecisa que seja 6.1.0-40-amd64 e sua versao atual é:<b> $(echo $vkernel)</b></big>" --button="gtk-close:1" --center --width=400 --height=100 --image="gtk-dialog-error"
			exit 0
		fi
		MenuDependenciaNitgen
}

MenuDependenciaNitgenHFDU06R(){
	DownDependenciaNitgenHFDU06R | yad --text-info --tail --title="Instalação Nitgen" --width="350" --height="320" --button="gtk-close:1" --center --no-buttons --auto-close
}

MenuDependenciaNitgen(){
	DownDependenciaNitgen | yad --text-info --tail --title="Instalação Nitgen" --width="350" --height="320" --button="gtk-close:1" --center --no-buttons --auto-close
}

DownDependenciaNitgenHFDU06R() {
    echo
    TMP_DIR="/tmp"
    ZIP_NAME="DependenciaNitgenLinuxHFDU06R.zip"
    DEST_DIR="$TMP_DIR/DependenciaNitgenLinuxHFDU06R"
    KER_VER=$(uname -r)
    DRIVER_PATH="/lib/modules/$KER_VER/kernel/drivers/usb/misc"
    DEVICE="ngstar"

    cd "$TMP_DIR" || exit 1
    echo "📥 Realizando download das dependências..."
    curl -u "$ftpUser:$ftpSenha" -O "$ftpHost/$ftpander/IsoMenuPdvM5/$ZIP_NAME"
    if [[ $? -ne 0 ]]; then
        echo "Erro ao realizar download"
        echo " --> ERRO... <--"
        echo " --> ESC PARA CONTINUAR. <--"
        exit 1
    else
        echo "Download realizado com sucesso!"
    fi
    echo

    echo "Extraindo arquivos..."
    unzip -o "$ZIP_NAME" -d "$DEST_DIR" >/dev/null 2>&1
    rm -f "$ZIP_NAME"

    echo "Iniciando reinstalação do driver NITGEN HFDU06R..."

    # Verifica se os arquivos existem
    for file in ngstarlib.so ngstardrv.ko ngstardrv.h ngstardrv.conf 99-Nitgen-ngstardrv.rules; do
        if [ ! -f "$DEST_DIR/$file" ]; then
            echo "Arquivo $file não encontrado em $DEST_DIR"
            exit 1
        fi
    done

    # Cria diretórios se necessário
    mkdir -p "$DRIVER_PATH"
    mkdir -p /usr/include/linux
    mkdir -p /etc/udev/rules.d

    # Copia arquivos com permissões corretas
    install -m 755 "$DEST_DIR/ngstarlib.so" /lib/
    install -m 644 "$DEST_DIR/ngstardrv.ko" "$DRIVER_PATH/"
    install -m 644 "$DEST_DIR/ngstardrv.h" /usr/include/linux/
    install -m 644 "$DEST_DIR/ngstardrv.conf" /etc/
    install -m 644 "$DEST_DIR/99-Nitgen-ngstardrv.rules" /etc/udev/rules.d/

    # Atualiza dependências do kernel
    depmod

    # Recarrega regras do udev
    udevadm control --reload-rules
    udevadm trigger

    # Recarrega módulo do kernel
    modprobe -r ngstardrv 2>/dev/null
    modprobe ngstardrv

	cp -rf eNBSP /usr/local/NITGEN/
	chmod +x /usr/local/NITGEN/eNBSP/bin/NBioBSP_Demo

	

    echo "Driver reinstalado com sucesso!"
    echo " --> ESC PARA CONTINUAR. <--"
	echo AGORA DEVE ABRIR O SDK EM 3 SEGUNDOS
	sleep 1
	ConfirmaUpdateConfigNitgen
	sleep 3
	wine /usr/local/NITGEN/eNBSP/bin/NBioBSP_Demo
	echo
    exit 0
}

DownDependenciaNitgen(){
	echo
	cd /tmp/
	echo "Realizando download dependencias"
	curl -u $ftpUser:$ftpSenha -O $ftpHost/$ftpander/IsoMenuPdvM5/DependenciaNitgenLinux.zip
		if [[ $? -ne 0 ]]; then
			echo "Erro ao realizar download"
			echo
			echo " -->ERRO... <--"
			echo
			echo " --> ESC PARA CONTINUAR. <--"
			exit 0
		else
		echo "OK!"
		fi
	echo
	echo "Instalando dependencioas"
	unzip -o DependenciaNitgenLinux.zip -d DependenciaNitgenLinux >/dev/null 2>&1
	rm DependenciaNitgenLinux.zip -f
	cd DependenciaNitgenLinux
	cp VenusDrv.ko /lib/modules/6.1.0-40-amd64/kernel/drivers/usb/misc/
	cp VenusDrv.h /usr/include/linux/
	cp 99-Nitgen-VenusDrv.rules /etc/udev/rules.d/
	cp -f VenusDrv.conf /etc/
	cp VenusLib.so /lib/
	cp NBioBSP.lic /lib/
	cp libNBioBSP.so /lib/
	chmod 777 controlid
	cp controlid /mnt/Aramo/MASTERBOX/
	chmod 777 nitgen
	cp nitgen /mnt/Aramo/MASTERBOX/
	if [ ! -d "/usr/local/NITGEN/" ]; then
        mkdir -p /usr/local/NITGEN/
    fi
	cp -rf eNBSP /usr/local/NITGEN/
	chmod +x /usr/local/NITGEN/eNBSP/bin/NBioBSP_Demo
	cp libaudio.so.2.4 /usr/lib/i386-linux-gnu/
	cp libQtCore.so.4.8.7 /usr/lib/i386-linux-gnu/
	cp libQtGui.so.4.8.7 /usr/lib/i386-linux-gnu/
	echo "Arquivos copiados com sucesso!!!"
	echo
	sleep 1
	cd /usr/lib/i386-linux-gnu/
	ln -s libQtGui.so.4.8.7 libQtGui.so.4.8
	ln -s libQtGui.so.4.8.7 libQtGui.so.4
	ln -s libQtCore.so.4.8.7 libQtCore.so.4.8
	ln -s libQtCore.so.4.8.7 libQtCore.so.4
	ln -s libaudio.so.2.4 libaudio.so.2
	echo "Links simbolicos criados!!!"
	sleep 1
	cd /lib/modules/6.1.0-40-amd64/kernel/drivers/usb/misc/
	echo
	/sbin/insmod VenusDrv.ko
	/sbin/depmod
	echo
	echo Comando /sbin/depmod executado
	sleep 1
	ConfirmaUpdateConfigNitgen
	echo
	echo " --> INSTALAÇÃO REALIZADA COM SUCESSO. <--"
	echo
	echo AGORA DEVE ABRIR O SDK EM 3 SEGUNDOS
	sleep 3
	wine /usr/local/NITGEN/eNBSP/bin/NBioBSP_Demo
	echo
	echo " --> ESC PARA CONTINUAR. <--"
	exit 0
}

MenuDependenciaControlid(){
	DownDependenciaControlid | yad --text-info --tail --title="Instalação control ID" --width="330" --height="190" --button="gtk-close:1" --center --no-buttons --auto-close
}

DownDependenciaControlid(){
	echo
	cd /tmp/
	echo "Realizando download dependencias"
	curl -u $ftpUser:$ftpSenha -O $ftpHost/$ftpander/IsoMenuPdvM5/DependenciaControlidLinux.zip
		if [[ $? -ne 0 ]]; then
			echo "Erro ao realizar download"
			echo
			echo " -->ERRO... <--"
			echo
			echo " --> ESC PARA CONTINUAR. <--"
			exit 0
		else
		echo "OK!"
		fi
	echo
	echo "Instalando dependencioas"
	unzip -o DependenciaControlidLinux.zip -d DependenciaControlidLinux >/dev/null 2>&1
	rm DependenciaControlidLinux.zip -f
	chmod 777 DependenciaControlidLinux/*
	cd DependenciaControlidLinux
	chmod 777 Dwindows/*
	cp Dwindows/* /mnt/Aramo/windows/
	chmod 777 /mnt/Aramo/windows/controlid
	chmod 777 /mnt/Aramo/windows/controlidext
	# rm DependenciaControlidLinux -f
	cd /usr/lib/
	ln -s /etc/alternatives/libblas.so.3 libblas.so.3 >/dev/null 2>&1
	ln -s libcidbio.so.1.4.3 libcidbio.so >/dev/null 2>&1
	ln -s libcidbio.so libcidbio.so.0 >/dev/null 2>&1
	cd /tmp/DependenciaControlidLinux
	cp Dusr/Dlib/* /usr/lib/
	echo "OK! Links criados."
	sleep 1
	echo
	ConfirmaUpdateconfigControlid
	echo " --> INSTALAÇÃO REALIZADA COM SUCESSO. <--"
	echo
	echo " --> ESC PARA CONTINUAR. <--"
	exit 0
}

ConfirmaUpdateconfigControlid() {

    yad --title="CONFIRMA UPDATE NA CONFIG E CONFIGNOVA?" --center --button="Não"!gtk-cancel:1 --button="Sim"!gtk-ok:0 --text="\nDeseja configurar o caixa para operar com a biometria ControliD? \n Aviso!!! \n  Vai ser feito update na config e confignova. \n O caixa  so vai funcionar com senha biometrica!! \n Confirmar update? \n confignova: \n operacao.biometria.tipo='EXT' \n config: \n tiposenhager ='BIO'" --image=gtk-execute --width=400 --escape-ok
    if [ $? == 0 ]; then
        UpdateConfignovaControlid
    fi

}

ConfirmaUpdateConfigNitgen() {

    yad --title="CONFIRMA UPDATE NA CONFIG E CONFIGNOVA?" --center --button="Não"!gtk-cancel:1 --button="Sim"!gtk-ok:0 --text="\nDeseja configurar o caixa para operar com a biometria Nitgen? \n Aviso!!! \n  Vai ser feito update na config e confignova. \n O caixa  so vai funcionar com senha biometrica!! \n Confirmar update? \n confignova: \n operacao.biometria.tipo='EXT' \n config: \n tiposenhager ='BIO'" --image=gtk-execute --width=400 --escape-ok
    if [ $? == 0 ]; then
        UpdateConfignovaNitgen
    fi

}

UpdateConfignovaControlid(){
	SetUpdateConfignovaControlid | yad --text-info --tail --title="Instalação control ID" --width="330" --height="190" --button="gtk-close:1" --center --no-buttons --auto-close
}

UpdateConfignovaNitgen(){
	SetUpdateConfignovaNitgen | yad --text-info --tail --title="Instalação control ID" --width="330" --height="190" --button="gtk-close:1" --center --no-buttons --auto-close
}

SetUpdateConfignovaControlid(){
	echo
	mastersql UpdateConfignovaBio
	sleep 1
	echo "OK! feito update na  config e confignova."
	echo
	echo " --> UPDATE REALIZADO COM SUCESSO. <--"
	echo
	echo " --> O CAIXA ESTA CONFIGURADO PARA BIOMETRIA. <--"
	echo
	echo " --> ESC PARA CONTINUAR. <--"
	exit 0
}

SetUpdateConfignovaNitgen(){
	echo
	mastersql UpdateConfignovaBioNitgen
	sleep 1
	echo "OK! feito update na  config e confignova."
	echo
	echo " --> UPDATE REALIZADO COM SUCESSO. <--"
	echo
	echo " --> O CAIXA ESTA CONFIGURADO PARA BIOMETRIA. <--"
	echo
	echo " --> ESC PARA CONTINUAR. <--"
	exit 0
}

ManuMasterBkp(){
		while :; do
			OPCAO6=$(
				yad --list \
				--title=" MANUTENÇÃO BACKUP " --text='Tecle ESC para voltar.' \
				--width=280 --height=320 --center \
				--column='OPCAO6':NUM --column='texto':TEXT \
				--window-icon="" --no-headers --print-column=1 --separator='' --hide-column=1 \
				600 '<big>Arquivos e configurações</big>' \
				601 '<big>Banco de dados</big>'\
				602 '<big>Backup geral</big>')
		[ $? -ne 0 ] && break
		case "$OPCAO6" in
		600)
			backuppdv FazBkpArqConfigs
			;;
		601)
			backuppdv FazBkpMasterboxManual
			;;
		602)
			backuppdv FazBkpManutencaoPdv
			;;
		esac
	done
}

setaConfgPadraoHiper(){
	configPadraoHiper | yad --text-info --tail --title="APLICANDO CONFIG PADRÃO HIPER" --width="320" --height="180" --button="gtk-close:1" --center --no-buttons --auto-close
}

configPadraoHiper(){
	resetmaster kill
	echo " --> EXECUTANDO CONFIG PADRÃO HIPER<--"
	echo 
	echo " --> FAZENDO UPDATE NO BANCO DE DADOS...<--"
	mastersql SetUpdateConfigSetHiper
	echo
	echo " --> OK <--"
	echo " --> CONFIGURADO PARA HIPER<--"
	echo 
	echo " --> CONCLUIDO! <--"
	echo
	echo " --> TECLA ESC PARA CONTINUAR. <--"
	echo
	echo
	sleep 1
	configIpHipersync
	exit 0
	
}

setaConfgPadraoSuperbox(){
	configPadraoSuperbox | yad --text-info --tail --title="APLICANDO CONFIG PADRÃO SUPERBOX" --width="320" --height="180" --button="gtk-close:1" --center --no-buttons --auto-close
}

configPadraoSuperbox(){
	resetmaster kill
	echo " --> EXECUTANDO CONFIG PADRÃO SUPERBOX<--"
	echo 
	echo " --> FAZENDO UPDATE NO BANCO DE DADOS...<--"
	mastersql SetUpdateConfigSetSuperbox
	echo
	echo " --> OK <--"
	echo " --> CONFIGURADO PARA SUPERBOX<--"
	echo 
	echo " --> CONCLUIDO! <--"
	echo
	echo " --> TECLA ESC PARA CONTINUAR. <--"
	echo
	echo
	sleep 1
	configIpSupersync
	exit 0
	
}

hdsetaverificaespaco(){
	hdverificaespaco | yad --text-info --tail --title="VERIFICA ESPAÇO EM DISCO" --width="320" --height="180" --button="gtk-close:1" --center --no-buttons --auto-close
}

hdverificaespaco(){
	espacoMinimo="5" # MB
	espacoLivre=$(df / -BG --output=avail | sed -n 2p | tr -dc '0-9')
	mensagem="ESPAÇO LIVRE: ${espacoLivre} GB."
	if [ $espacoLivre -lt $espacoMinimo ]; then
  	echo " --> MINIMO DEFINIDO ${espacoMinimo}GB <--"
	echo
	echo " --> DISPONIVEL ${espacoLivre}GB. ATENÇÃO!!<--"
	echo
	else
  	echo " --> ESPAÇO LIVRE ATUAL: ${espacoLivre}GB. <--"
	echo
	fi
	echo " --> VERIFICAÇÃO CONCLUIDA! <--"
	echo
	echo " --> TECLA ESC PARA CONTINUAR. <--"
	exit 0
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