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
sudo apt-get install -y nano gcc g++ make wget htop curl git git-core build-essential libssl-dev php-cli php-zip iotop unzip
Update

echo "-- Install NodeJS --"
sudo curl -sL https://deb.nodesource.com/setup_11.x | bash -
sudo apt-get install -y nodejs yarn
Update

echo "-- Install NodeJS Modules--"
sudo npm update -g
npm install node-sass gulp gulp-sass gulp-prettier gulp-cssnano --save-dev

# Install Apache and modules required to run Grav
echo "-- Install Apache --"
sudo add-apt-repository ppa:ondrej/apache2 -y
sudo apt-get install -y apache2
sudo a2enmod rewrite
Update

echo "-- Install PHP --"
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
sudo ln -fs /vagrant/public/ /var/www/app
cat << EOF | sudo tee -a /etc/apache2/sites-available/default.conf
<Directory "/var/www/">
    AllowOverride All
    Require all granted
</Directory>

<VirtualHost *:80>
    DocumentRoot /var/www/grav
    ServerName 800grad.local
</VirtualHost>
EOF
sudo a2ensite default.conf

echo "-- Restart Apache --"
sudo systemctl restart apache2

echo "-- Install Composer --"
curl -s https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
sudo chmod +x /usr/local/bin/composer

#install grav
composer create-project getgrav/grav /var/www/

#remove default grav userfolder and clone correct one
cd /var/www/
rm -rf user
git clone --recurse-submodules https://github.com/800grad/user.git
