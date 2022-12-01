<h1> RoutingLoopCheck</h1>
<p>
    Este é um script em Shell, que verifica possíveis loops de roteamento</br>
em sub-redes e retorna uma lista de hosts que podem estar com loop,</br>
analisando do ponto de vista da rede de origem de execução do script.</br>
O script verifica através do comando fping, se os hosts de uma determinada rede</br>
apresentam resposta do tipo **ICMP Time Exceeded** e gera uma lista contendo estes hosts.</br>
A partir desta lista, o script pode gerar um log e notificações via email e/ou telegram.</br>
OBS: Para enviar a notificação por email, você precisará do pacote **mailutils** instalado.
</p>

    ^$ apt install mailutils
 
<h2>Como utilizar o script:</h2>
<p>1 - Defina seus parâmetros no arquivo de configuração routingloopcheck.conf</p>

<p>2 - Você pode definir um texto padrão que será enviado no corpo do email de notificação</br>
    Há disponível neste repositório, um texto elaborado por mim que explica de forma clara</br>
    como resolver o problema de loop de roteamento.</p>
<p>3 - Você pode executar o script manualmente ou criar um agendamento no cron para executar periodicamente.</br>
    Minha sugestão é a execução uma vez por semana.</br>
    Para isso, adicione estas linhas no final do arquivo /etc/crontab, onde **65535** é o seu ASN</p>
    
    #RoutingLoopCheck
    0 2 * * 1 root /etc/routingloopcheck.sh 65535 >/dev/null 2>&1
    
<p>ou</p>    

    #RoutingLoopCheck
    0 2 * * 1 root /etc/routingloopcheck.sh -c 65535 >/dev/null 2>&1
    
</p>Em seguida, reinicie o cronjob:</p>
    
    ~$ systemctl restart cron
   
 <p>Para verificar os CIDR de um ASN específico, execute o script, informando o ASN a ser verificado</p>
 
    ~$ routingloopcheck.sh 65535
 
 <p>Utilizando este comando, o script irá realizar uma consulta no whois.nic.br, coletar quais os CIDR IPv4</br>
 alocados para este AS e verificar se há loops de roteamento nas sub-redes deste CIDR.</p>
 <p>Você pode realizar uma análise em lotes, informando vários ASNs.</p>

    ~$ routingloopcheck.sh 65535 65534 65533

Utilizando o comando abaixo:

    ~$ routingloopcheck.sh -c 65535

O script irá consultar a política de roteamento **AS-in** cadastrada no nic.br, verificar quem são os AS que estão no cone</br>
de downstream, coletar quais são os CIDR alocados aos mesmos e verificar se há loop de roteamento.</br>
O script irá considerar como cone de downstream, as políticas de roteamento definidas como **accept AS65535**, como no exemplo</br>
da imagem abaixo:

![Alt text](./screenshots/routingloop_whois.png?raw=true )

<p>Exemplo de notificação por Email:</p>

![Alt text](./screenshots/routingloop_email.png?raw=true )

<p>Exemplo de notificação por Telegram:</p>

![Alt text](./screenshots/routingloop_telegram.png?raw=true )

