#!/bin/sh

BOOTSTRAPPED="/etc/vagrant-bootstrapped"
if [ ! -e $BOOTSTRAPPED ]; then

  # Update apt lists
  apt-get update

  # Keyring
  apt-get install debian-keyring debian-archive-keyring

  # Build toolchain
  apt-get install -y curl build-essential git-core

  # Apache
  apt-get install -y apache2 apache2-mpm-prefork

  # MySQL
  DEBIAN_FRONTEND=noninteractive  apt-get install -y mysql-server mysql-client
  mysqladmin -u root password flow

  # PHP
  apt-get install -y php5 php5-dev php-pear

  # Node.js
  #curl -sL https://deb.nodesource.com/setup_0.10 | bash -
  #apt-get install -y nodejs

  # Ruby
  #apt-get install -y ruby ruby-dev

  # Solr
  #apt-get install -y solr-jetty

  # Vim
  apt-get install -y vim

  # Sync configuration files (again during provosioning)
  rsync --keep-dirlinks -recursive --perms --owner --group /vagrant/vagrant/config/root/ /
  chown -R vagrant /home/vagrant


  ### PHP extensions
  apt-get install -y php5-curl php5-gd imagemagick php5-imagick php5-mcrypt php5-mysql php5-xdebug


  pecl install uploadprogress
  echo `find /usr/lib/php5/ | grep uploadprogress.so | awk '{print "\nextension=" $1}'` > /etc/php5/mods-available/uploadprogress.ini
  php5enmod uploadprogress

  # Composer
  curl -sS https://getcomposer.org/installer | php
  mv composer.phar /usr/local/bin/composer
  ln -s /usr/local/bin/composer /usr/bin/composer

  ### Drush 8
  #composer global require drush/drush:dev-master
  git clone -b master https://github.com/drush-ops/drush.git /usr/local/src/drush
  cd /usr/local/src/drush
  ln -s /usr/local/src/drush/drush /usr/bin/drush
  # Patch composer.lock to remove php5-readline which isn't available on wheezy
  sed -i '/^\s*"ext-readline": "\*",$/d' composer.lock
  composer install

  # Node packages
  #sudo npm install -g grunt-cli

  # Ruby gems
  #gem install compass oily_png

  # Link /var/www
  rm -rf /var/www/
  ln -s /vagrant /var/www
  mkdir -p /var/www/private
  chown -R www-data:www-data /var/www

  # Set new home directory
  usermod -d /var/www/ vagrant

  # Fix ssh agent forwarding when using sudo
  echo "Defaults    env_keep += \"SSH_AUTH_SOCK\"" > /etc/sudoers.d/99_root_ssh_agent

  # Fix apache lock dir
  chown -R vagrant /var/lock/apache2

  # Enable apache modules
  a2enmod expires
  a2enmod rewrite
  a2enmod ssl

  a2dissite 000-default
  a2ensite vagrant

  # Restart apache
  service apache2 restart

  # Create empty database
  mysql -e "DROP DATABASE IF EXISTS drupal;"
  mysql -e "CREATE DATABASE drupal;"
  mysql -e "GRANT ALL ON drupal.* TO vagrant@localhost IDENTIFIED BY 'v4gr4nt'"

  # Eye candy
  echo "alias l='ls --color=auto -lah'" >> /root/.bashrc
  echo "alias l='ls --color=auto -lah'" >> /home/vagrant/.bashrc
  echo "if [ -f ~/.drush_bashrc ] ; then . ~/.drush_bashrc ; fi" >> /home/vagrant/.bashrc

  touch $BOOTSTRAPPED
  echo "Done boostrapping vm"

else
  echo "VM already boostrapped"
fi
