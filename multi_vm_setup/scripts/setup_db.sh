#!/bin/bash

echo "---Installing MySQl---"
sudo apt update
sudo DEBIAN_FRONTEND=noninteractive apt install -y mysql-server


echo "---Configuring MysSQL"
sudo mysql -e "CREATE DATABASE wordpress;"
sudo mysql -e "CREATE USER 'wpuser'@'%' IDENTIFIED BY 'wppass';"
sudo mysql -e "GRANT ALL PRIVILEGES ON wordpress.* TO 'wpuser'@'%';"
sudo sed -i "s/bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/mysql.conf.d/mysql.cnf
sudo systemctl restart mysql
