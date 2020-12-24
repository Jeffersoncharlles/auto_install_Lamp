#!/usr/bin/env bash
##########################################################################
##########################################################################
#=========+++++++++SCRIPT INSTALL APACHE MYSQL PHP+++++++++++=============
#
#Autor: Jefferson Charlles
#Data Criacao:22/11/2020
#
#Descricao: Script auto instalador php apache e mariadb
#
#====Versao 1.1
###########################################################################
# Histórico:
#
#   v1.0 22/11/2020, Jefferson:
#       - Início do programa
#
#   v1.1 23/11/2020, Jefferson:
#       - comecando a organizar o programa#   
#       
#   v1.2 02/12/2020, Jefferson:
#       - password md5 altogerador#  	
#	
#   v1.3 02/12/2020, Jefferson:
#       - melhorias no codigo espacamento nos textos e refaturamento de codigos#  		
# ------------------------------------------------------------------------#
# ------------------------------- VARIÁVEIS ------------------------------#
# opção do comando date: +%T (Time)
HORAINICIAL=`date +%T`
LOG="/var/log/$(echo $0 | cut -d'/' -f2)"
USUARIO=`id -u`
UBUNTU=`lsb_release -rs`
KERNEL=$(uname -r)
HOSTNAME=$(hostname)
CPUNO=$(cat /proc/cpuinfo |grep "model name" | wc -l) #numero de processador
CPUMODEL=$(cat /proc/cpuinfo |grep "model name" | head -n1|cut -c14-) #modelo do processador
MEMTOTAL=$(expr $(cat /proc/meminfo |grep MemTotal|tr -d ' '|cut -d: -f2|tr -d kB) / 1024) # em mb
UPTIME=$(uptime -s)

PASSWORD=$(date +%s | sha256sum | base64 | head -c 32) 
USER="root"

#CORES
AMARELO="\033[33;1m"
CINZACLARRO="\033[37;1m"
VERDE="\033[32;1m"
VERMELHO="\033[31;1m"
ZERARR="\033[0m"

# ------------------------------------------------------------------------#
# ------------------------------------------------------------------------#
echo -e "==========================================================="
echo -e "Relatorio da Maquina: $HOSTNAME"
echo -e "Data/Hora: $(date)"
echo -e "==========================================================="
echo -e
echo -e "Maquina Ativa desde: $UPTIME"
echo -e
echo -e "Versao do Kernel: $KERNEL"
echo -e
echo -e "CPUs:"
echo -e "Quantidade de Cpus/Core: $CPUNO"
echo -e "Modelo da Cpu: ${AMARELO}$CPUMODEL${ZERARR}"
echo -e
echo -e "Memoria Total: ${AMARELO}$MEMTOTAL MB${ZERARR}"
# ------------------------------------------------------------------------#
# Verificando se o usuário é Root, Distribuição é >=20.04 <IF MELHORADO)
# [ ] = teste de expressão, && = operador lógico AND, == comparação de string, exit 1 = A maioria dos erros comuns na execução
# Variáveis de configuração do MySQL e liberação de conexão remota para o usuário Root

clear
if [ "$USUARIO" == "0" ] && [ "$UBUNTU" == "20.04" ]
	then
		echo -e "O usuário é Root, continuando com o script..."
		echo -e "Distribuição é >=20.04.x, continuando com o script..."
		sleep 5
	else
		echo -e "Usuário não é Root ($USUARIO) ou Distribuição não é >=20.04.x ($UBUNTU)"
		echo -e "Caso você não tenha executado o script com o comando: sudo -i"
		echo -e "Execute novamente o script para verificar o ambiente."
		exit 1
fi
#
echo "####################################################################################"
echo "#########################----------update----#######################################"
echo -e
sudo apt-get update >>$LOG
echo "#########################----------upgrade----#######################################"
echo "####################################################################################"
echo -e
sudo apt-get full-upgrade -y >>$LOG
echo "#########################----------unzip--git----####################################"
echo "####################################################################################"
echo -e
sudo apt-get install wget unzip git -y >>$LOG
echo "#########################----------apache2----#######################################"
echo "####################################################################################"
echo -e
sudo apt-get install apache2 -y >>$LOG
echo "#########################----------php7.4----#######################################"
echo "####################################################################################"
echo -e
sudo apt-get install php7.4 php7.4-cli php7.4-curl php7.4-gd php7.4-json php7.4-xml php7.4-zip php7.4-mbstring php7.4-mysql -y >>$LOG
echo "#########################----------mariadb----#######################################"
echo "####################################################################################"
echo -e
sudo apt-get install mariadb-server -y >>$LOG
echo -e
echo "####################################################################################"
echo "####################################################################################"
echo -e
# ------------------------------------------------------------------------#
ADMINUSER=$USER
GRANTALL="GRANT ALL ON *.* TO $USER@'%' IDENTIFIED BY '$PASSWORD';"
FLUSH="FLUSH PRIVILEGES;"
# ------------------------------------------------------------------------#
echo -e "SENHA PASSWORD GERADO ALTOMATICAMENTE UNICA : ${AMARELO}$PASSWORD${ZERARR}"
echo -e
#mysql_secure_installation
#Políticas de Segurança do MariaDB
sudo mysql_secure_installation
1. Enter current password for root (enter for none): $PASSWORD <Enter>
2. Change the root password? [Y/n]: y <Enter>
3. New password: aulaead <Enter>
4. Re-enter new password: aulaead <Enter>
5. Remove anonymous users? [Y/n]: y <Enter>
6. Disallow root login remotely? [Y/n]: n <Enter>
7. Remove test database and access to it? [Y/n]: n <Enter>
8. Reload privilege tables now? [Y/n]: y <Enter>

echo -e "Permitindo o Root do MySQL se autenticar remotamente, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando mysql: -u (user), -p (password) -e (execute)
	mysql -u $USER -p$PASSWORD -e "$GRANTALL" mysql &>> $LOG
	mysql -u $USER -p$PASSWORD -e "$FLUSH" mysql &>> $LOG

#CREATE USER 'user'@'localhost' INDENTIFIED BY 'senhausuario';
#GRANT ALL PRIVILEGES ON *.* TO 'user'@'localhost' WITH GRANT OPTION;
exit >>$LOG
echo "#########################----------Restart-aplicacao----###################################"
a2enmod suexec rewrite include
systemctl restart apache2
echo -e
echo -e "####################################################################################"
echo -e "##################### PARABENS TERMINOU O PROCESSO #################################"
echo -e "####################################################################################"
echo -e "####################################################################################"
echo -e "Instalação do LAMP-SERVER feito com Sucesso!!!"
# script para calcular o tempo gasto (SCRIPT MELHORADO, CORRIGIDO FALHA DE HORA:MINUTO:SEGUNDOS)
# opção do comando date: +%T (Time)
HORAFINAL=`date +%T`
# opção do comando date: -u (utc), -d (date), +%s (second since 1970)
HORAINICIAL01=$(date -u -d "$HORAINICIAL" +"%s")
HORAFINAL01=$(date -u -d "$HORAFINAL" +"%s")
# opção do comando date: -u (utc), -d (date), 0 (string command), sec (force second), +%H (hour), %M (minute), %S (second), 
	TEMPO=`date -u -d "0 $HORAFINAL01 sec - $HORAINICIAL01 sec" +"%H:%M:%S"`
# $0 (variável de ambiente do nome do comando)
echo -e "Tempo gasto para execução do script $0: $TEMPO"
echo -e "Pressione <Enter> para concluir o processo."
# opção do comando date: + (format), %d (day), %m (month), %Y (year 1970), %H (hour 24), %M (minute 60)
echo -e "Fim do script $0 em: `date +%d/%m/%Y-"("%H:%M")"`\n" &>> $LOG
read
exit 1
#sudo apt install phpmyadmin