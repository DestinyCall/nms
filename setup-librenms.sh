#!/usr/bin/env bash

echo "Librenms configuration starting..."
cdecho "Installing dependencie and required packages..."
apt-get -y install acl curl fping git graphviz imagemagick mariadb-client mariadb-server mtr-tiny nginx-full nmap php-cli php-curl php-fpm php-gd php-gmp php-json php-mbstring php-mysql php-snmp php-xml php-zip rrdtool snmp snmpd whois unzip python3-pymysql python3-dotenv python3-redis python3-setuptools python3-systemd python3-pip
echo "Adding librenms user and giving ownership of /opt/librenms directory..."
useradd librenms -d /opt/librenms -M -r -s "$(which bash)"
cd /opt
git clone https://github.com/librenms/librenms.git
chown -R librenms:librenms /opt/librenms
chmod 771 /opt/librenms
setfacl -d -m g::rwx /opt/librenms/rrd /opt/librenms/logs /opt/librenms/bootstrap/cache/ /opt/librenms/storage/
setfacl -R -m g::rwx /opt/librenms/rrd /opt/librenms/logs /opt/librenms/bootstrap/cache/ /opt/librenms/storage/
su - librenms
./scripts/composer_wrapper.php install --no-dev
exit

sed -i'.bak' '/date.timezone/a \date.timezone = Asia/Kolkata' /etc/php/8.1/fpm/php.ini
sed -i'.bak' '/date.timezone/a \date.timezone = Asia/Kolkata' /etc/php/8.1/cli/php.ini

timedatectl set-timezone Asia/Kolkata

sed -i'.bak' '/[mysqld]/a \innodb_file_per_table=1 \lower_case_table_names=0' /etc/mysql/mariadb.conf.d/50-server.cnf

systemctl enable mariadb
systemctl restart mariadb

echo "Creating database..."

mysql -uroot -e "CREATE DATABASE librenms CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

echo "Creating database user..."

mysql -uroot -e "CREATE USER 'librenms'@localhost IDENTIFIED BY 'password';"
mysql -uroot -e "GRANT ALL PRIVILEGES ON librenms.* TO 'librenms'@'localhost';"
mysql -uroot -e "FLUSH PRIVILEGES;"

echo "database config success!"

echo "Configuration of fpm pool for librenms!"

cp /etc/php/8.1/fpm/pool.d/www.conf /etc/php/8.1/fpm/pool.d/librenms.conf

sudo sed -i'.bak' '/[www]/a \[librenms]' /etc/php/8.1/fpm/pool.d/librenms.conf

# user = librenms
# group = librenms
# listen = /run/php-fpm-librenms.sock

# #vi /etc/nginx/conf.d/librenms.conf

# server {
#  listen      80;
#  server_name librenms.example.com;
#  root        /opt/librenms/html;
#  index       index.php;

#  charset utf-8;
#  gzip on;
#  gzip_types text/css application/javascript text/javascript application/x-javascript image/svg+xml text/plain text/xsd text/xsl text/xml image/x-icon;
#  location / {
#   try_files $uri $uri/ /index.php?$query_string;
#  }
#  location ~ [^/]\.php(/|$) {
#   fastcgi_pass unix:/run/php-fpm-librenms.sock;
#   fastcgi_split_path_info ^(.+\.php)(/.+)$;
#   include fastcgi.conf;
#  }
#  location ~ /\.(?!well-known).* {
#   deny all;
#  }
# }

# rm /etc/nginx/sites-enabled/default
# systemctl restart nginx
# systemctl restart php8.1-fpm

# ln -s /opt/librenms/lnms /usr/bin/lnms
# cp /opt/librenms/misc/lnms-completion.bash /etc/bash_completion.d/
# cp /opt/librenms/snmpd.conf.example /etc/snmp/snmpd.conf

# sudo sed -i'.bak' '/RANDOMSTRINGGOESHERE/a \upl' /etc/snmp/snmpd.conf

# curl -o /usr/bin/distro https://raw.githubusercontent.com/librenms/librenms-agent/master/snmp/distro
# chmod +x /usr/bin/distro
# systemctl enable snmpd
# systemctl restart snmpd

# cp /opt/librenms/dist/librenms-scheduler.service /opt/librenms/dist/librenms-scheduler.timer /etc/systemd/system/

# systemctl enable librenms-scheduler.timer
# systemctl start librenms-scheduler.timer

# cp /opt/librenms/misc/librenms.logrotate /etc/logrotate.d/librenms

# chown librenms:librenms /opt/librenms/config.php

# sudo su - librenms
# ./validate.php

# pip3 install -r requirements.txt
# exit

# cp /opt/librenms/misc/librenms.service /etc/systemd/system/librenms.service && systemctl enable --now librenms.service
