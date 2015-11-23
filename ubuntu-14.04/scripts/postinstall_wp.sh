#!/bin/bash
databasePass="Metallica21"
triggerCreateDB="/var/log/databasesetup"
sudo locale-gen "en_US.UTF-8"
export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8
rootPass="Metallica21"

echo mysql-server mysql-server/root_password password "$rootPass" | sudo debconf-set-selections
echo mysql-server mysql-server/root_password_again password "$rootPass" | sudo debconf-set-selections

sudo apt-get update
sudo aptitude install -y --add-user-tag tag.aptitude
sudo aptitude install -y --add-user-tag tag.apache2 apache2 
sudo aptitude install -y --add-user-tag tag.php php5 libapache2-mod-php5 php5-mcrypt php5-gd libssh2-php 
sudo aptitude install -y --add-user-tag tag.admin_tools htop unzip 
sudo aptitude install -y --add-user-tag tag.mysql-server mysql-server php5-mysql

### Fixed bug with shadow symbols
#sed s/^M// /home/vagrant/files_provision/configure_mysql.sh > filename.tmp && mv filename.tmp /home/vagrant/files_provision/configure_mysql.sh
### Configure DB
if [ ! -f "$triggerCreateDB" ];
then
	echo "CREATE USER 'wp'@'localhost' IDENTIFIED BY '12345'" | mysql -uroot -p"$rootPass"
	echo "CREATE DATABASE wordpress" | mysql -uroot -p"$rootPass"
	echo "GRANT ALL ON wordpress.* TO 'wp'@'localhost'" | mysql -uroot -p"$rootPass"
	echo "FLUSH PRIVILEGES" | mysql -uroot -p"$rootPass"
	sudo touch "$triggerCreateDB" && chmod 400 "$triggerCreateDB"
fi
### Preparing of Wordpress application
wget -P /var/www/html https://wordpress.org/latest.zip &>>/dev/null
cd /var/www/html 
unzip latest.zip >>/dev/null 
rm latest.zip
# sudo cp -R /home/vagrant/files_provision/WordPress/ /var/www/html/ $$ sudo chown -R :www-data /var/www/html/*
mkdir -p /var/www/html/wp-content/uploads && sudo chown -R :www-data /var/www/html/
mv /var/www/html/wordpress/* /var/www/html/ && rm /var/www/html/wordpress
cp /home/vagrant/files_provision/wp-config.php /var/www/html/
### Preparing Apache2
sudo sed -i s/index.html/index.php/g /etc/apache2/mods-enabled/dir.conf
sudo sed -i s/index.php/index.html/2 /etc/apache2/mods-enabled/dir.conf
service apache2 restart