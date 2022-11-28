#!/bin/bash


 ############################################################
 # Verificação de loop de roteamento                        #
 # by Evandro Alves (for Intercol)                          #
 # Versão 1.2811722                                         #
 # Documentacao completa em:                                #
 # wiki.intercol.com.br/Verificação_de_loop_de_roteamento   #
 ############################################################

if [ -z ${1} ] ; then
        echo "Você precisa especificar o ASN a ser verificado"
        echo "Usage example: ./netloopcheck.sh 65535"
        exit 1
fi
#
#
#Altere estas variáveis conforme o ambiente 
#
#Endereço IP do servidor zabbix
ZBX_SRV=127.0.0.1
#
#Nome do host configurado no zabbix para receber os dados
NAME_HOST=NETLOOPCHECK
#
#Habilita o envio dos dados para o zabbix
END_TO_ZABBIX=NO
#
#Habilita o envio dos dados por email
SEND_EMAIL=YES
DST_MAIL=suporte@intercol.com.br
#
#
#
#
declare -a ASNARRAY=("$@")
for ASN in "${ASNARRAY[@]}"
do
INETNUM=`whois -h whois.nic.br "$ASN" 2>&1 | grep -w 'inetnum:' | grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\/([0-9]){1,2}\b'`
#
        declare -a CIDRARRAY=($INETNUM)
        for CIDR in "${CIDRARRAY[@]}"
                do
                        declare -a HOSTARRAY=( `fping -gae "$CIDR" 2>&1 | grep -Fi time | cut -d" " -f 11` )
                        if [ ${#HOSTARRAY[@]} -eq 0 ]; then
#Envia resultados para o ZABBIX
                                if [ "$SEND_TO_ZABBIX" = YES ] ; then
                                zabbix_sender -z ${ZBX_SRV} -s ${NAME_HOST} -k routing.loop.hosts -o "${ASN} - Nenhum loop de roteamento identificado" >/dev/null 2>&1
                                zabbix_sender -z ${ZBX_SRV} -s ${NAME_HOST} -k routing.loop.status -o 0 >/dev/null 2>&1
                                fi
#Envia resultados por email
                                if  [ "$SEND_EMAIL" = YES ] ; then
                                        echo "Nenhum loop de roteamento identificado para o AS ${ASN}" |  mail -s "Nenhum loop de roteamento identificado para o AS ${ASN}" $DST_MAIL >/dev/null 2>&1
                                fi
                        else
#Envia resultaods para o ZABBIX
                                if [ "$SEND_TO_ZABBIX" = YES ] ; then
                                        zabbix_sender -z ${ZBX_SRV} -s ${NAME_HOST} -k routing.loop.status -o 1 >/dev/null 2>&1
                                        for HOST in "${HOSTARRAY[@]}"
                                        do
                                                zabbix_sender -z ${ZBX_SRV} -s ${NAME_HOST} -k routing.loop.hosts -o "${ASN} - ${HOST} - Possível loop de roteamento identificado" >/dev/null 2>&1
                                        done
                                fi
#Envia resultados por email
                                if  [ "$SEND_EMAIL" = YES ] ; then
                                        printf "%s\n" "${HOSTARRAY[@]}" |  mail -s "Possível loop de roteamento no AS ${ASN}" $DST_MAIL  >/dev/null 2>&1
                                fi
                        fi
        done
done
#
#Final do script
