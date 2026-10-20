#!/bin/bash
# Installs and configures WordPress on Ubuntu 20.04 (Apache, MySQL, PHP).
# Run inside the VM:   sudo bash /vagrant/setup.sh 'YourDatabasePassword'
# Note: the password must not contain the characters | or & (it is used with sed).

set -e

DB_NAME="wordpress"
DB_USER="wordpress"
DB_PASS="${1:?Usage: sudo bash setup.sh 'YourDatabasePassword'}"

echo ">>> Installing packages"
apt update
apt install -y apache2 ghostscript libapache2-mod-php mysql-server php php-bcmath \
  php-curl php-imagick php-intl php-json php-mbstring php-mysql php-xml php-zip

echo ">>> Downloading WordPress to /srv/www/wordpress"
mkdir -p /srv/www
chown www-data: /srv/www
if [ ! -d /srv/www/wordpress ]; then
  curl -s https://wordpress.org/latest.tar.gz | sudo -u www-data tar zx -C /srv/www
fi

echo ">>> Creating the Apache site"
cat > /etc/apache2/sites-available/wordpress.conf << 'APACHE'
<VirtualHost *:80>
    DocumentRoot /srv/www/wordpress
    <Directory /srv/www/wordpress>
        Options FollowSymLinks
        AllowOverride Limit Options FileInfo
        DirectoryIndex index.php
        Require all granted
    </Directory>
    <Directory /srv/www/wordpress/wp-content>
        Options FollowSymLinks
        Require all granted
    </Directory>
</VirtualHost>
APACHE
a2ensite wordpress
a2enmod rewrite
a2dissite 000-default || true

echo ">>> Creating the database and user"
mysql -e "CREATE DATABASE IF NOT EXISTS ${DB_NAME};"
mysql -e "CREATE USER IF NOT EXISTS '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';"
mysql -e "ALTER USER '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';"
mysql -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost'; FLUSH PRIVILEGES;"

echo ">>> Connecting WordPress to the database"
CONFIG=/srv/www/wordpress/wp-config.php
if [ ! -f "$CONFIG" ]; then
  sudo -u www-data cp /srv/www/wordpress/wp-config-sample.php "$CONFIG"
fi
sudo -u www-data sed -i "s|database_name_here|${DB_NAME}|" "$CONFIG"
sudo -u www-data sed -i "s|username_here|${DB_USER}|" "$CONFIG"
sudo -u www-data sed -i "s|password_here|${DB_PASS}|" "$CONFIG"

echo ">>> Checking and restarting Apache"
apache2ctl configtest
systemctl enable apache2 mysql
systemctl restart apache2

echo ">>> Done. Open http://<vm-ip-address> in your browser to finish the WordPress setup."
