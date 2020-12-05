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
# ------------------------------------------------------------------------#
# ------------------------------- VARIÁVEIS ------------------------------#
LOG="/var/log/$(echo $0 | cut -d'/' -f2)"
KERNEL=$(uname -r)
HOSTNAME=$(hostname)
CPUNO=$(cat /proc/cpuinfo |grep "model name" | wc -l) #numero de processador
CPUMODEL=$(cat /proc/cpuinfo |grep "model name" | head -n1|cut -c14-) #modelo do processador
MEMTOTAL=$(expr $(cat /proc/meminfo |grep MemTotal|tr -d ' '|cut -d: -f2|tr -d kB) / 1024) # em mb
UPTIME=$(uptime -s)

PASSWORD=$(date +%s | sha256sum | base64 | head -c 32) 

#CORES
AMARELO="\033[33;1m"
CINZACLARRO="\033[37;1m"
VERDE="\033[32;1m"
VERMELHO="\033[31;1m"
ZERARR="\033[0m"

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
echo "####################################################################################"
echo "#########################----------update----#######################################"
sudo apt-get update >>$LOG
echo "#########################----------upgrade----#######################################"
sudo apt-get full-upgrade -y >>$LOG
echo "#########################----------unzip--git----####################################"
sudo apt-get install wget unzip git -y >>$LOG
echo "#########################----------apache2----#######################################"
sudo apt-get install apache2 -y >>$LOG
echo "#########################----------php7.4----#######################################"
sudo apt-get install php7.4 php7.4-cli php7.4-curl php7.4-gd php7.4-json php7.4-xml php7.4-zip php7.4-mbstring php7.4-mysql -y >>$LOG
echo "#########################----------mariadb----#######################################"
sudo apt-get install mariadb-server -y >>$LOG
echo "####################################################################################"
echo "####################################################################################"
echo "$PASSWORD"
echo -e
mysql_secure_installation 

mysql -uroot GRANT ALL PRIVILEGES ON *.* TO 'superadmin'@'localhost' IDENTIFIED BY '$PASSWORD';

#CREATE USER 'user'@'localhost' INDENTIFIED BY 'senhausuario';
#GRANT ALL PRIVILEGES ON *.* TO 'user'@'localhost' WITH GRANT OPTION;
exit
echo "#########################----------Restart-aplicacao----###################################"
a2enmod suexec rewrite include
systemctl restart apache2

#sudo apt install phpmyadmin