#!/bin/bash
user=root
senha=152100
base=masterbox
nomepdv=$(cat /etc/hostname)
caminhobkp="/mnt/Aramo/BACKUP"
data=`date +%d-%m-%Y`
datahoraminuto=`date +%d-%m-%Y-%H:%M`
caminhobkpmanualbanco="/mnt/Aramo/BACKUP/$nomepdv"
#export PGPASSWORD=pg29766*


UpdateConfignovaBioNitgen(){
	mysql -u$user -p$senha $base -e "update confignova set valor ='EXT' where propriedade ='operacao.biometria.tipo'"
	mysql -u$user -p$senha $base -e "update config set tiposenhager ='BIO'"
}

UpdateConfignovaBio(){
	mysql -u$user -p$senha $base -e "update confignova set valor ='EXT' where propriedade ='operacao.biometria.tipo'"
	mysql -u$user -p$senha $base -e "update config set tiposenhager ='BIO'"
}

FazBkpmasterboxManual(){
	mysqldump -u$user -p$senha $base > $caminhobkpmanualbanco/masterbox_bkp_manual.$nomepdv.$data.sql
}

FazBackupInfNfce(){
	mv $caminhobkp/SQL/*.sql $caminhobkp/SQL/old/
	mysql -u$user -p$senha $base -e "select * from infnfce" >> $caminhobkp/SQL/BKP_infnfce_select.texto
	mysqldump -u$user -p$senha $base -n infnfce >$caminhobkp/SQL/BKP_infnfce_tabela_$datahoraminuto.sql
}

SetHostNfceHiper(){
	mysql -u$user -p$senha $base -e "update config set HOSTNFCE ='http://$1:8080/hipersync/hipernfce', HOSTPONTOS ='http://$1:8080/hipersync/clubedesconto'"
}

SetHostNfceSuperbox(){
	mysql -u$user -p$senha $base -e "update config set HOSTNFCE ='http://$1:8080/SuperSyncEjb/syncservice/syncservice', HOSTPONTOS ='http://$1:8080/SuperSyncWeb/clubedesconto'"
}

SetInfNFCesql(){
	mysql -u$user -p$senha $base -e "INSERT INTO infnfce ( INFNFCE_ID, IDLOJA, SERIE, NUMNFCE, IDCUPOM, AMBIENTE) VALUES (1, $1, $2, $3, 0, 1)
ON DUPLICATE KEY UPDATE
INFNFCE_ID ='1',
IDLOJA ='$1',
SERIE ='$2',
NUMNFCE ='$3',
IDCUPOM ='0',
AMBIENTE ='1';"
}

SetUpdateConfigSetHiper(){
    mysql -u$user -p$senha $base -e "INSERT INTO config ( IDCONFIG ,  MAX_VALORCANC ,  MAX_VALORCANCCUPOM ,  MAX_RETIRADA ,  F1PORLISTA ,  LBCANCOPER ,  LBGAVOPER ,  TIPOSCP ,  SERVIDORMATRIZ ,  BANCOMATRIZ ,  PROTOMATRIZ ,  USERMATRIZ ,  PASSWMATRIZ ,  PORTAMATRIZ ,  FINPOS ,  ZSTARTUP ,  LOCCLIENTECPF ,  MOSTRASALDODEV ,  MENSAGEM1 ,  MENSAGEM2 ,  MENSAGEM3 ,  SANGRIAFISCAL ,  PREFIXEANINTERNO ,  EMAILREDUCAOZ ,  EMAILBLOQSANGRIA ,  EMAILBLOQENCARTE ,  EMAILIMPORTACAO ,  EMAILCARGA ,  EMAILTECNICO ,  EMAILGERENTE ,  SERVEREMAIL ,  USEREMAIL ,  PASSWDEMAIL ,  PORTAEMAIL ,  DESABENTERVAZIO ,  HABTROCOCHEQUE ,  PAPAFILA ,  SERVIDORPAPAFILA ,  BANCOPAPAFILA ,  TIPOSENHAGER ,  BLOQUEIAX ,  RECEBMANUAL ,  PREVENDA ,  PARANOTOTAL ,  TEMPOLIMPATELA ,  BLOQAUTHPAG ,  PROTOBALANCA ,  VERIFESTOQUE ,  MAXDIASCHEQUE ,  CODIGOACOUGUE ,  IDENTIFICAVENDEDOR ,  LISTAPREVENDA ,  DESCITEMGERAL ,  NAOTRAVASANGRIA ,  HABCARRETO ,  VALORCUPOMCARRETO ,  HABFOTOPESAVEL ,  HABPROMOVALOR ,  DESABCOMPPROMO ,  TIPOMASTERNET ,  PORTAMASTERNET ,  UNIDADE_LOJA ,  ADICIONAPREFIXOEAN ,  QTDDIGCODIGO ,  HABILITACONSULTA ,  TAXASERVICO ,  HORAINITAXA ,  HORAFIMTAXA ,  MODODIG ,  QTDECODDIG ,  TIPONFCE ,  HOSTNFCE ,  PORTANFCE ,  TIMEOUTNFCE ,  FORCACPFCUPOM ,  MODOCODAGOUGUE ,  DESCONTONOITEM ,  HOSTPONTOS ,  TIPOCODCLI ,  PEDESENHACONV ,  QTDEVIASCONV ,  TIPOFECHAMENTO ,  EANPORVALOR ,  TIPOEVENTOS ,  HABDESCCONV ,  SENHADESCCONV ,  MOSTRADADOSCLI ,  SENHACONS ,  PRECOPACKFIN ,  IMPRIMEDESCONTOITEM ,  IDTABLOJA ,  MAXVALORCUPOM ,  BINDTCP ,  HABPROMOVALORX ,  AUDITAPESO ,  TOLAUDITAPESO ,  PESOMINAUDITAPESO ,  FORCACLUBE ,  VERSAONFCE ,  DESABECHO ,  TIPOETQBAL ,  TIMEOUTREAD ,  FORCACPFCUPOMTOTAL ,  CPFMANSEMCOD ,  QRCODELATERAL ,  DANFEFANT ,  VERSAOQRCODE ,  CONFCOMP ,  FECHAFISICO ,  TIPOTEF ,  LIBDIVERPESO ,  CLUBEVALIDAZAP ,  CAPTURAFONEPINPAD ,  CONVENIOUNICO ,  LISTATEFF2 ,  CONTROLAVGIMP ,  EANINTCDV ,  CONTROLASACOLA ,  ENDCOMPSCP ,  CVALECONTROL ,  ATIVALOG ,  CONVENIOPARCELADO ,  IMPCOMANDA ,  FINTECLA ,  CNPJTEF ,  TIPOAUDITAPESO ,  TIPOCODPOS ,  HABVALORABERTURA ,  HABAUTHABERTURA ,  HABAUTHREIMP ,  HABPINGNFCE ,  TIPOCONFHIPER ,  PREVENDAUNICA ,  QTDEVIASBAIXACONV ,  CONFIRMALIBERACAO ,  PERMSEMCRIPTO ,  BLOQCARGA ,  CONSULTAPROMO ,  COMPCVALE ) VALUES (1, NULL, NULL, NULL, 'T', NULL, NULL, 'HSYNC', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'T', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'T', 'F', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'T', NULL, NULL, NULL, NULL, NULL, 'T', NULL, NULL, NULL, NULL, NULL, 4, NULL, NULL, NULL, NULL, NULL, 1, 'HSYNC', 'http://localhost:8080/hipersync/hipernfce', 8080, 3500, NULL, 'DVE', 'T', NULL, NULL, NULL, NULL, 2, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'T', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'T', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'T', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'T', NULL)
ON DUPLICATE KEY UPDATE
IDCONFIG= '1',
F1PORLISTA='T',
TIPOSCP='HSYNC',
MOSTRASALDODEV='T',
PREVENDA='T',
PARANOTOTAL='F',
LISTAPREVENDA='T',
HABPROMOVALOR='T',
QTDDIGCODIGO='4',
QTDECODDIG='1',
TIPONFCE ='HSYNC',
HOSTNFCE ='http://localhost:8080/hipersync/hipernfce',
PORTANFCE ='8080',
TIMEOUTNFCE ='3500',
MODOCODAGOUGUE ='DVE',
DESCONTONOITEM='T',
HOSTPONTOS='http://localhost:8080/hipersync/clubedesconto',
TIPOFECHAMENTO ='2',
IMPRIMEDESCONTOITEM='T',
CPFMANSEMCOD='T',
CVALECONTROL='T',
CONSULTAPROMO='T';"
}

SetUpdateConfigSetSuperbox(){
    mysql -u$user -p$senha $base -e "INSERT INTO config ( IDCONFIG ,  MAX_VALORCANC ,  MAX_VALORCANCCUPOM ,  MAX_RETIRADA ,  F1PORLISTA ,  LBCANCOPER ,  LBGAVOPER ,  TIPOSCP ,  SERVIDORMATRIZ ,  BANCOMATRIZ ,  PROTOMATRIZ ,  USERMATRIZ ,  PASSWMATRIZ ,  PORTAMATRIZ ,  FINPOS ,  ZSTARTUP ,  LOCCLIENTECPF ,  MOSTRASALDODEV ,  MENSAGEM1 ,  MENSAGEM2 ,  MENSAGEM3 ,  SANGRIAFISCAL ,  PREFIXEANINTERNO ,  EMAILREDUCAOZ ,  EMAILBLOQSANGRIA ,  EMAILBLOQENCARTE ,  EMAILIMPORTACAO ,  EMAILCARGA ,  EMAILTECNICO ,  EMAILGERENTE ,  SERVEREMAIL ,  USEREMAIL ,  PASSWDEMAIL ,  PORTAEMAIL ,  DESABENTERVAZIO ,  HABTROCOCHEQUE ,  PAPAFILA ,  SERVIDORPAPAFILA ,  BANCOPAPAFILA ,  TIPOSENHAGER ,  BLOQUEIAX ,  RECEBMANUAL ,  PREVENDA ,  PARANOTOTAL ,  TEMPOLIMPATELA ,  BLOQAUTHPAG ,  PROTOBALANCA ,  VERIFESTOQUE ,  MAXDIASCHEQUE ,  CODIGOACOUGUE ,  IDENTIFICAVENDEDOR ,  LISTAPREVENDA ,  DESCITEMGERAL ,  NAOTRAVASANGRIA ,  HABCARRETO ,  VALORCUPOMCARRETO ,  HABFOTOPESAVEL ,  HABPROMOVALOR ,  DESABCOMPPROMO ,  TIPOMASTERNET ,  PORTAMASTERNET ,  UNIDADE_LOJA ,  ADICIONAPREFIXOEAN ,  QTDDIGCODIGO ,  HABILITACONSULTA ,  TAXASERVICO ,  HORAINITAXA ,  HORAFIMTAXA ,  MODODIG ,  QTDECODDIG ,  TIPONFCE ,  HOSTNFCE ,  PORTANFCE ,  TIMEOUTNFCE ,  FORCACPFCUPOM ,  MODOCODAGOUGUE ,  DESCONTONOITEM ,  HOSTPONTOS ,  TIPOCODCLI ,  PEDESENHACONV ,  QTDEVIASCONV ,  TIPOFECHAMENTO ,  EANPORVALOR ,  TIPOEVENTOS ,  HABDESCCONV ,  SENHADESCCONV ,  MOSTRADADOSCLI ,  SENHACONS ,  PRECOPACKFIN ,  IMPRIMEDESCONTOITEM ,  IDTABLOJA ,  MAXVALORCUPOM ,  BINDTCP ,  HABPROMOVALORX ,  AUDITAPESO ,  TOLAUDITAPESO ,  PESOMINAUDITAPESO ,  FORCACLUBE ,  VERSAONFCE ,  DESABECHO ,  TIPOETQBAL ,  TIMEOUTREAD ,  FORCACPFCUPOMTOTAL ,  CPFMANSEMCOD ,  QRCODELATERAL ,  DANFEFANT ,  VERSAOQRCODE ,  CONFCOMP ,  FECHAFISICO ,  TIPOTEF ,  LIBDIVERPESO ,  CLUBEVALIDAZAP ,  CAPTURAFONEPINPAD ,  CONVENIOUNICO ,  LISTATEFF2 ,  CONTROLAVGIMP ,  EANINTCDV ,  CONTROLASACOLA ,  ENDCOMPSCP ,  CVALECONTROL ,  ATIVALOG ,  CONVENIOPARCELADO ,  IMPCOMANDA ,  FINTECLA ,  CNPJTEF ,  TIPOAUDITAPESO ,  TIPOCODPOS ,  HABVALORABERTURA ,  HABAUTHABERTURA ,  HABAUTHREIMP ,  HABPINGNFCE ,  TIPOCONFHIPER ,  PREVENDAUNICA ,  QTDEVIASBAIXACONV ,  CONFIRMALIBERACAO ,  PERMSEMCRIPTO ,  BLOQCARGA ,  CONSULTAPROMO ,  COMPCVALE ) VALUES (1, NULL, NULL, NULL, 'T', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'T', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'T', 'F', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'T', NULL, NULL, NULL, NULL, NULL, 'T', NULL, NULL, NULL, NULL, NULL, 4, NULL, NULL, NULL, NULL, NULL, 1, NULL, 'http://localhost:8080/SuperSyncEjb/syncservice/syncservice', 8080, 3500, NULL, NULL, 'T', NULL, NULL, NULL, NULL, 2, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'T', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'T', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'T', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'T', NULL)
ON DUPLICATE KEY UPDATE  
IDCONFIG= '1',
F1PORLISTA='T',
TIPOSCP= null,
MOSTRASALDODEV='T',
PREVENDA='T',
PARANOTOTAL='F',
LISTAPREVENDA='T',
HABPROMOVALOR='T',
QTDDIGCODIGO='4',
QTDECODDIG='1',
TIPONFCE = null,
HOSTNFCE ='http://localhost:8080/SuperSyncEjb/syncservice/syncservice',
PORTANFCE ='8080',
TIMEOUTNFCE ='3500',
MODOCODAGOUGUE = null,
DESCONTONOITEM='T',
HOSTPONTOS='http://localhost:8080/SuperSyncWeb/clubedesconto',
TIPOFECHAMENTO ='2',
IMPRIMEDESCONTOITEM='T',
CPFMANSEMCOD='T',
CVALECONTROL='F',
CONSULTAPROMO='T';"
}

###############################################################################################################
#									SQL FIREBIRD AQUI EM BAIXO.									#
###############################################################################################################
# ConsultaDoctoFirebird(){
# 	isql-fb -U SYSDBA -p masterkey 192.168.1.162:/banco/firebird/SUPERBOXNOVO.FDB -i select max(numnfe) from pdv
# where serie ='888' -o teste.txt
# }

ConsultaNumnfceFirebird(){
	touch /tmp/consulta.firebird.sql
	sql="/tmp/consulta.firebird.sql"
	echo -e "select max(numnfe) from pdv where idloja ='$1' and serie ='$2';" >$sql
	isql-fb -U SYSDBA -p masterkey $3:$4 -i $sql -o $caminhobkp/SQL/pdv.numnfce.$data.consulta
	
}

UpdateInfNfceConsultaFirebird(){
	mysql -u$user -p$senha $base -e "INSERT INTO infnfce ( INFNFCE_ID, IDLOJA, SERIE, NUMNFCE, IDCUPOM, AMBIENTE) VALUES (1, $1, $2, 0, 0, 1)
ON DUPLICATE KEY UPDATE  
INFNFCE_ID ='1',
IDLOJA ='$1',
SERIE ='$2',
NUMNFCE ='0',
IDCUPOM ='0',
AMBIENTE ='1';"
	numnfce=$(tr -d '' < $caminhobkp/SQL/pdv.numnfce.$data.consulta | sed -n 4p | sed 's/ *$//g')
	mysql -u$user -p$senha $base -e "update infnfce set numnfce=${numnfce} where idloja='$1' and serie ='$2'"
	sleep 3
	#echo movendo $docto PARA OLD
	mv $caminhobkp/SQL/pdv.numnfce.$data.consulta $caminhobkp/SQL/old/pdv.numnfce.$datahoraminuto.consulta
	rm /tmp/consulta.firebird.sql
}

###############################################################################################################
#									SQL POSTGRES AQUI EM BAIXO.									#
###############################################################################################################

ConsultaDoctoPostgres(){
	export PGPASSWORD=$(tr -d '' < /tmp/senhapg.senha | sed -n 1p | sed 's/ *$//g')
	psql -U postgres -h $3 -p $4 -d aramo -c "select max(mn.lcpr_dcto) from pdv.lctoprodutos_pdv mn where mn.lcpr_serie = '$2' and mn.lcpr_codempresa='$1'" > /mnt/Aramo/BACKUP/SQL/lctoprodutos_pdv.$data.consulta	
	rm /tmp/senhapg.senha
	rm /tmp/portapg.porta
}

UpdateInfNfceConsultaPostgres(){
	mysql -u$user -p$senha $base -e "INSERT INTO infnfce ( INFNFCE_ID, IDLOJA, SERIE, NUMNFCE, IDCUPOM, AMBIENTE) VALUES (1, $1, $2, 0, 0, 1)
ON DUPLICATE KEY UPDATE  
INFNFCE_ID ='1',
IDLOJA ='$1',
SERIE ='$2',
NUMNFCE ='0',
IDCUPOM ='0',
AMBIENTE ='1';"
	docto=$(tr -d '' < $caminhobkp/SQL/lctoprodutos_pdv.$data.consulta | sed -n 3p | sed 's/ *$//g')
	mysql -u$user -p$senha $base -e "update infnfce set numnfce=${docto} where idloja='$1' and serie ='$2'"
	sleep 3
	#echo movendo $docto PARA OLD
	mv $caminhobkp/SQL/lctoprodutos_pdv.$data.consulta $caminhobkp/SQL/old/lctoprodutos_pdv.$datahoraminuto.consulta
}

###############################################################################################################
#										CASE AQUI EM BAIXO.										#
###############################################################################################################

case $1 in

	SetUpdateConfigSetHiper)		
		SetUpdateConfigSetHiper
	;;
	SetUpdateConfigSetSuperbox)		
		SetUpdateConfigSetSuperbox
	;;
	SetHostNfceHiper)
		SetHostNfceHiper $2
	;;
	SetHostNfceSuperbox)
		SetHostNfceSuperbox $2
	;;
	SetInfNFCesql)
		SetInfNFCesql $2 $3 $4
	;;
	FazBackupInfNfce)
		FazBackupInfNfce
	;;
	FazBkpmasterboxManual)
		FazBkpmasterboxManual
	;;
	ConsultaDoctoPostgres)
		ConsultaDoctoPostgres $2 $3 $4 $5
	;;
	ConsultaNumnfceFirebird)
		ConsultaNumnfceFirebird $2 $3 $4 $5
	;;
	UpdateInfNfceConsultaPostgres)
		UpdateInfNfceConsultaPostgres $2 $3 $4
	;;
	UpdateInfNfceConsultaFirebird)
		UpdateInfNfceConsultaFirebird $2 $3
	;;
	UpdateConfignovaBio)
		UpdateConfignovaBio
	;;
	UpdateConfignovaBioNitgen)
		UpdateConfignovaBioNitgen
	;;
esac
exit 0