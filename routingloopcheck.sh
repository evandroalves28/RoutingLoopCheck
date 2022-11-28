#!/bin/bash


 ############################################################
 # Verificação de loop de roteamento                        #
 # by Evandro Alves (for Intercol)                          #
 # Versão 1.281172203                                       #
 # Documentacao completa em:                                #
 # https://github.com/evandroalves28/RoutingLoopCheck       #
 ############################################################

#
#
#Altere estas variáveis conforme o ambiente 
#
#Habilita o registro de logs
SAVE_LOG=NO
#LOG_PATH=/var/log/
#Habilita o envio dos dados por email
SEND_EMAIL=NO
DST_MAIL=root@localhost
#
#
#
#
if [ -z ${1} ] ; then
        echo "Você precisa especificar o ASN a ser verificado"
        echo "Usage example: ./routingloopcheck.sh 65535 #Irá testar os CIDR alocados para o AS65535"
        echo "\n"
        echo "Usage example: ./routingloopcheck.sh 65535 65534#Irá testar os CIDR alocados para os AS65535 e AS65534"
        echo "\n"        
        echo "Usage example: ./routingloopcheck.sh -c 65535 #Irá testar os CIDR alocados para os clientes do AS65535"
        echo "Obs: compativel somente quando a route policy esta declarada no nic.br"
        exit 1
fi

if [ ${1} = "-c" ] ; then
        declare -a ASNARRAY=(`whois -h whois.nic.br "$2" 2>&1 | grep -w 'as-in:' |  grep -oE 'accept AS([0-9]{1,6})' | grep -oE '([0-9]{1,6})'`)
else
        declare -a ASNARRAY=("$@")
fi

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
