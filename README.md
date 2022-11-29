<h1> RoutingLoopCheck</h1>
Este é um script em Shell, que verifica possíveis loops de roteamento</br>
em sub-redes e retorna uma lista de hosts que podem estar com loop,</br>
analisando do ponto de vista da rede de origem de execução do script.</br>

Esta versão possibilita 2 formas de execução: </br>

Para verificar os CIDR de um ASN específico, execute o script, informando o ASN a ser verificado</br>
~$ routingloopcheck.sh **AS-NUMBER**

Para verificar os CIDR alocados aos aos ASN do cone de DOWNSTREAM de um ASN específico, execute no formato abaixo:</br>
~$ routingloopcheck.sh -c **AS-NUMBER**</br>
O Script irá consultar no whois do nic.br quais são os CIDR IPv4 alocados</br>
para este AS e executar uma verificação através do aplicativo fping, se possui algum host desse CIDR contém algum possível loop de roteamento.</br>

O resultado poderá ser enviado via email.</br>
