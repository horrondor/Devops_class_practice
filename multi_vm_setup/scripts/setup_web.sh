#!/bin/bash

echo "--- Installing Apache2, PHP, and wordpress ---"

sudo apt update
sudo apt install -y  apache2 \
                 ghostscript \
                 libapache2-mod-php \
                 mysql-server \
                 php \
                 php-bcmath \
                 php-curl \
                 php-imagick \
                 php-intl \
                 php-json \
                 php-mbstring \
                 php-mysql \
                 php-xml \
                 php-zip

#Installing wordpress
sudo mkdir -p /srv/www
sudo chown www-data: /srv/www
curl https://wordpress.org/latest.tar.gz | sudo -u www-data tar zx -C /srv/www

echo "--- Configuring Wordpress ---"

#cp /var/www/html/wordpress/wp-config-sample.php /var/www/html/wordpress/wp-config.php

sudo -u www-data cp /srv/www/wordpress/wp-config-sample.php /srv/www/wordpress/wp-config.php


# Setup wp-config.php

# sed -i "s/database_name_here/wordpress/" /var/www/html/wordpress/wp-config.php
# sed -i "s/username_here/wpuser/" /var/www/html/wordpress/wp-config.php
# sed -i "s/password_here/wppass/" /var/www/html/wordpress/wp-config.php
# sed -i "s/localhost/192.168.56.11/" /var/www/html/wordpress/wp-config.php

sudo -u www-data sed -i 's/database_name_here/wordpress/' /srv/www/wordpress/wp-config.php
sudo -u www-data sed -i 's/username_here/wordpress/' /srv/www/wordpress/wp-config.php
sudo -u www-data sed -i 's/password_here/<your-password>/' /srv/www/wordpress/wp-config.php

# Allow Apache .htaccess overrides
cat << EOF | sudo tee /etc/apache2/sites-available/wordpress.conf
<<comment
 <VirtualHost *:80>
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/html/wordpress
    <Directory /var/www/html/wordpress>
        AllowOverride All
        Require all granted
    </Directory>
 </VirtualHost>
comment

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
EOF

sudo a2ensite wordpress
sudo a2enmod rewrite
sudo a2dissite 000-default
# sudo systemctl reload apache2
# sudo systemctl restart apache2
sudo service apache2 reload

# Install WP-CLI (WordPress CLI tool)
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/local/bin/wp

cd /var/www/html/wordpress

# Setup WordPress from CLI
sudo -u www-data wp core install --url="http://192.168.56.10" --title="DevOps Blog" \
    --admin_user=admin --admin_password=admin123 --admin_email=admin@example.com

# Create blog post
<<comment 
sudo -u www-data wp post create --post_title="My Everyday As A DevOps" \
    --post_content="This is my daily journey as a DevOps engineer." --post_status=publish
comment
