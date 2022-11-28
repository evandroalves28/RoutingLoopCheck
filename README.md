# RoutingLoopCheck
Este é um script em Shell, que verifica possíveis loops de roteamento
em sub-redes e retorna uma lista de hosts que podem estar com loop,
analisando do ponto de vista da rede de origem de execução do script.

Esta versão possibilita 1 forma de execução: 
~$ routingloopcheck.sh <AS-NUMBER> 

O Script irá consultar no whois do nic.br quais são os CIDR IPv4 alocados
para este AS e executar uma verificação através do aplicativo fping, se
possui algum host desse CIDR contém algum possível loop de roteamento.

O resultado poderá ser enviado via email.
