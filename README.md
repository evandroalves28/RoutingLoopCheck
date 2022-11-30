<h1> RoutingLoopCheck</h1>
Este é um script em Shell, que verifica possíveis loops de roteamento</br>
em sub-redes e retorna uma lista de hosts que podem estar com loop,</br>
analisando do ponto de vista da rede de origem de execução do script.</br>
O script verifica através do comando fping, se os hosts de uma determinada rede</br>
apresentam resposta do tipo **ICMP Time Exceeded** e gera uma lista contendo estes hosts.</br>
A partir desta lista, o script pode gerar um log e notificações via email e/ou telegram.</br>

Como utilizar o script:

1 - Defina seus parâmetros no arquivo de configuração routingloopcheck.conf</br>
2 - Você pode definir um texto padrão que será enviado no corpo do email de notificação</br>
    Há disponível neste repositório, um texto elaborado por mim que explica de forma clara</br>
    como resolver o problema de loop de roteamento.</br>
3 - Você pode executar o script manualmente ou criar um agendamento no cron para executar periodicamente.</br>
    Minha sugestão é a execução uma vez por semana.</br>
    Para isso, adicione estas linhas no final do arquivoo /etc/crontab, onde **65535** é o seu ASN</br>
    
    #RoutingLoopCheck.sh
    0 2 * * 1 root /etc/routingloopcheck.sh 65535 >/dev/null 2>&1
    
ou    
    #RoutingLoopCheck.sh
    0 2 * * 1 root /etc/routingloopcheck.sh -c 65535 >/dev/null 2>&1
    
Em seguida, reinicie o cronjob:</br>
    
    ~$ sustemctl restart cron
   
 Para verificar os CIDR de um ASN específico, execute o script, informando o ASN a ser verificado</br>
 
 ~$ routingloopcheck.sh 65535
 
 Utilizando este comando, o script irá realizar uma consulta no whois.nic.br, coletar quais os CIDR IPv4</br>
 alocados para este AS e verificar se há loops de roteamento nas sub-redes deste CIDR.</br>

#

Utilizando o comando abaixo:

~$ routingloopcheck.sh -c 65535

O script irá consultar a política de roeamento **AS-in** cadastrada no nic.br, verificar quem são os AS que estão no cone</br>
de downstream, coletar quais são os CIDR alocados aos mesmos e verificar se há loop de roteamento.</br>
O script irá considerar como cone de downstream, as políticas de roteamento definidas como **accept AS65535**, como no exemplo</br>
da imagem abaixo:
![Alt text](./imagem_2022-11-30_084652337.png?raw=true "Title")

Exemplo de notificação por Email:
![Alt text](./routingloop_email.png?raw=true "Title")

Exemplo de notificação por Telegram:
![Alt text](./imagem_2022-11-30_091705650.png?raw=true "Title")

