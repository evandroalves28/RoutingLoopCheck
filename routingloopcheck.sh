#!/bin/bash
############################################################
# Verificação de loop de roteamento                        #
# by Evandro Alves                                         #
# Versão 1.29112022                                        #
# Documentacao completa em:                                #
# https://github.com/evandroalves28/RoutingLoopCheck       #
# Arquivo de execução do script                            #
############################################################
#
#
source ./routingloopcheck.conf #Arquivo de configuração
#
#
do_log() {
	LOG_DATE="$(date '+%Y%m%d')"
	LOG_FILE_NAME=routingloopcheck_${LOG_DATE}_AS${ASN}.log
	LOG=${LOG_PATH}/${LOG_FILE_NAME}
	if [ ! -e $LOG_PATH ]; then
		mkdir $LOG_PATH
	fi	
	echo -e "$@">>$LOG

		
}

proof_test() {
	echo -e "\nSegue abaixo o teste de prova realizado em $# hosts">>$LOG
	declare -a PROOF_HOSTS=("$@")
	for PROOF_HOST in "${PROOF_HOSTS[@]}"; do
		echo -e "\n$(traceroute -n -w 1 $PROOF_HOST)" >>$LOG
	done
}

envia_telegram()
{
	if [ -z $TOKEN ] || [ -z $CHAT_EU ] || [ -z $TELEGRAM_API ]; then
		echo -e "Não foi possível enviar a mensagem.\nVerifique os parametros: TOKEN, CHAT_EU e TELEGRAM_API"
		exit 1
	fi
		curl -v -F "chat_id=$CHAT_EU" -F document=@$LOG -F caption="$@" $TELEGRAM_API &>/dev/null
		return
	
}

if [ -z ${1} ] ; then
		echo -e "\n"
        echo "Você precisa especificar o ASN a ser verificado"
        echo "Usage example: ./routingloopcheck.sh 65535 #Irá testar os CIDR alocados para o AS65535"
        echo "Usage example: ./routingloopcheck.sh 65535 65534#Irá testar os CIDR alocados para os AS65535 e AS65534"
        echo "Usage example: ./routingloopcheck.sh -c 65535 #Irá testar os CIDR alocados para os clientes do AS65535"
        echo "Obs: compativel somente quando a route policy esta declarada no nic.br"
        exit 1
fi

executar() {
	if [ ${1} = "-c" ] ; then
		declare -a ASNARRAY=(`whois -h whois.nic.br "$2" 2>&1 | grep -w 'as-in:' |  grep -oE 'accept AS([0-9]{1,6})' | grep -oE '([0-9]{1,6})'`)
	else
		declare -a ASNARRAY=("$@")
	fi
	for ASN in "${ASNARRAY[@]}"
		do
		INETNUM=`whois -h whois.nic.br "$ASN" 2>&1 | grep -w 'inetnum:' | grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\/([0-9]){1,2}\b'`
			declare -a CIDRARRAY=($INETNUM)
			for CIDR in "${CIDRARRAY[@]}"
            do
                declare -a HOSTARRAY=( `fping -gae "$CIDR" 2>&1 | grep -Fi time | cut -d" " -f 11` )

                    if [ ${#HOSTARRAY[@]} -eq 0 ] ; then
						MSG="Nenhum loop de roteamento identificado no AS$ASN"

						#Salva log
						if [ $SAVE_LOG = YES ] ; then
							do_log "$MSG"
						fi

						#Envia resultados por email
						if  [ $SEND_EMAIL = YES ] ; then
                            echo "$MSG" |  mail -s "$MSG" $DST_MAIL >/dev/null 2>&1
						fi

						#Envia pelo Telegram
						if [ $SEND_TELEGRAM = YES ] ; then
							envia_telegram "$MSG"
						fi
                    else
						MSG="Possível loop de roteamento no AS$ASN"

						#Salva log
						if [ $SAVE_LOG = YES ] ; then
							do_log "DATA       HORA     ASN		HOST"
							for HOST in "${HOSTARRAY[@]}"
								do
									do_log "$(date '+%d/%m/%Y %H:%M:%S') $ASN $HOST"
								done
							do_log "Processo finalizado"
						fi
						#Realiza teste de prova
						if [ $PROOF_TEST = YES ]; then
							if [ ${#HOSTARRAY[@]} == 1 ]; then proof_test "${HOSTARRAY[0]}";
							elif [ ${#HOSTARRAY[@]} > 1 ]; then proof_test "${HOSTARRAY[0]}" "${HOSTARRAY[${#HOSTARRAY[@]}-1]}" ; 
							fi
						fi

						#Envia resultados por email
                        if  [ $SEND_EMAIL = YES ] ; then
							declare -a MAIL_LIST=("$NOC_MAIL" "$(if [ $NOTIFY_AS = YES ]; then $(whois -h whois.nic.br "$ASN" 2>&1 | grep -w 'e-mail:' | cut -d ':' -f2); fi )")
							for MAIL_CONTACT in ${MAIL_LIST[@]}; do
								printf "%s\n""$(if [ ${BODY_TEMPLATE} = YES ]; then cat ${BODY_TEMPLATE_FILE}; fi)\n$(if [ ${BODY_LOG} = YES ]; then cat ${LOG}; fi)" |  mail -s "$MSG" $(if [ $ATTACH_LOG = YES ]; then echo "-A $LOG"; fi) $MAIL_CONTACT  >/dev/null 2>&1
							done
						fi

						#Envia pelo Telegram
						if [ $SEND_TELEGRAM = YES ] ; then
							envia_telegram "$MSG"
						fi
                    fi
			done
		done
}
if [ $CLEAR_BEFORE_START = YES ]; then
	clear
fi

executar $@
#
#Final do script
