#!/bin/bash


 ############################################################
 # Verificação de loop de roteamento                        #
 # by Evandro Alves (for Intercol)                          #
 # Versão 1.2811722                                         #
 # Documentacao completa em:                                #
 # https://github.com/evandroalves28/RoutingLoopCheck   #
 ############################################################

#
#
#Altere estas variáveis conforme o ambiente 
#
#Habilita o envio dos dados por email
SEND_EMAIL=YES
DST_MAIL=suporte@intercol.com.br
#
#
#
#
if [ -z ${1} ] ; then
        echo "Você precisa especificar o ASN a ser verificado"
        echo "Usage example: ./netloopcheck.sh 65535"
        exit 1
fi
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
#Envia resultados por email
                                if  [ "$SEND_EMAIL" = YES ] ; then
                                        echo "Nenhum loop de roteamento identificado para o AS ${ASN}" |  mail -s "Nenhum loop de roteamento identificado para o AS ${ASN}" $DST_MAIL >/dev/null 2>&1
                                fi
                        else
#Envia resultados por email
                                if  [ "$SEND_EMAIL" = YES ] ; then
                                        printf "%s\n" "${HOSTARRAY[@]}" |  mail -s "Possível loop de roteamento no AS ${ASN}" $DST_MAIL  >/dev/null 2>&1
                                fi
                        fi
        done
done
#
#Final do script
