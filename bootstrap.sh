#!/bin/bash

# mixins
Update () {
    echo "-- Update packages --"
    sudo apt-get update -y; sudo apt-get upgrade -y; sudo apt-get autoremove -y
}

#the real install process
echo "-- update system --"
Update
sudo apt-get dist-upgrade -y

echo "-- Install tools and helpers --"
sudo apt-get install -y nano gcc g++ make wget htop curl git git-core ch build-essential libssl-dev php-cli php-zip iotop unzip
Update

echo "-- Make it fishy --"
curl -L https://get.oh-my.fish | fish

echo "-- Install NodeJS --"
sudo curl -sL https://deb.nodesource.com/setup_11.x | bash -
sudo apt-get install -y nodejs yarn
sudo npm update -g
echo "-- Install NodeJS Modules--"
sudo npm install node-sass gulp gulp-sass gulp-prettier gulp-cssnano -g
Update

# Install Apache and modules required to run Grav
echo "-- Install Apache --"
sudo add-apt-repository ppa:ondrej/apache2 -y
sudo apt-get install -y apache2
sudo a2enmod rewrite
Update

echo "-- Install PHP --"
sudo apt-get purge php7.*
Update
sudo add-apt-repository ppa:ondrej/php -y
Update
sudo apt-get install -y libmcrypt-dev php7.3 php7.3-bcmath php7.3-cli php7.3-common php7.3-curl php7.3-dev php7.3-fpm php7.3-gd php7.3-intl php7.3-json php7.3-mbstring php7.3-opcache php7.3-xml php7.3-zip libapache2-mod-php7.3 php-apcu
Update

echo "-- Configure PHP &Apache --"
sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/7.3/apache2/php.ini
sed -i "s/display_errors = .*/display_errors = On/" /etc/php/7.3/apache2/php.ini
sudo a2enmod rewrite proxy_fcgi setenvif
sudo a2enconf php7.3-fpm
sudo systemctl restart apache2
Update

echo "-- Creating virtual hosts --"
# Link local grav files to VM apache
sudo rm -rf /var/www/html
sudo ln -fs /grav /var/www/html

# Install virtual host config
VHOST=$(cat <<EOF
<VirtualHost *:80>
  DocumentRoot /var/www/html/grav

  <Directory /var/www/html>
    AllowOverride All
    Require all granted
  </Directory>

  ErrorLog /var/log/apache2/error.log
  CustomLog /var/log/apache2/access.log combined
</VirtualHost>
EOF
)
sudo echo "${VHOST}" > /etc/apache2/sites-available/000-default.conf

echo "-- Restart Apache --"
sudo systemctl restart apache2

echo "-- Install Composer --"
curl -s https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
sudo chmod +x /usr/local/bin/composer

#install grav
cd /var/www/html/
composer create-project getgrav/grav /var/www/html/grav/
cd grav
rm -rf user
git clone --recurse-submodules https://github.com/800grad/user.git
