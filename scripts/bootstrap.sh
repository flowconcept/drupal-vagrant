#!/bin/sh

# Configure basic system without gems, npm packages, etc. that require a cachier reconfiguration.

BOOTSTRAPPED="/etc/vagrant-bootstrapped"
if [ ! -e $BOOTSTRAPPED ]; then

  # Update home directory:
  usermod -d /var/www/ vagrant

  apt-get -y update

  # Upgrade libssl
  DEBIAN_FRONTEND=noninteractive  apt-get upgrade -y libssl1.0.0

  # Build toolchain
  apt-get install -y curl build-essential git-core

  # Apache
  apt-get install -y apache2 apache2-mpm-prefork

  # MySQL
  DEBIAN_FRONTEND=noninteractive  apt-get install -y mysql-server mysql-client
  mysqladmin -u root password flow

  # PHP
  apt-get install -y php5 php5-dev php-pear

  # ImageMagick
  apt-get install -y imagemagick

  # PHP extensions
  apt-get install -y php5-curl php5-gd php5-imagick php5-mcrypt php5-mysql php5-xdebug

  pecl install uploadprogress
  echo `find /usr/lib/php5/ | grep uploadprogress.so | awk '{print "\nextension=" $1}'` > /etc/php5/mods-available/uploadprogress.ini
  php5enmod uploadprogress

  # Drush
  sudo pear channel-discover pear.drush.org
  sudo pear install drush/drush-5.10.0.0
  sudo drush --version

  # Solr
  #apt-get install -y solr-jetty

  # Ruby
  apt-get install -y ruby ruby-dev

  # Ruby gems
  gem install compass oily_png --conservative --no-rdoc --no-ri

  # Vim
  apt-get install -y vim

  # Link /var/www
  rm -rf /var/www/
  ln -s /vagrant /var/www
  mkdir -p /var/www/private
  chown -R www-data:www-data /var/www

  # SSH config
  sudo -u vagrant -H cp /vagrant/vagrant/config/ssh/* /home/vagrant/.ssh/
  sudo -u vagrant -H chmod 740 /home/vagrant
  sudo -u vagrant -H chmod 740 /home/vagrant/.ssh
  sudo -u vagrant -H chmod 600 /home/vagrant/.ssh/id_rsa
  sudo -u vagrant -H chmod 740 /home/vagrant/.ssh/authorized_keys

  # Sync configuration files (done again in config.sh)
  rsync --keep-dirlinks -recursive --perms --owner --group /vagrant/vagrant/config/root/ /
  chown -R vagrant /home/vagrant

  # Fix apache lock dir
  chown -R vagrant /var/lock/apache2

  # Enable apache modules
  a2enmod expires
  a2enmod rewrite
  a2enmod ssl

  a2dissite default
  a2ensite vagrant

  # Restart apache
  /etc/init.d/apache2 restart

  # Create empty database
  mysql -uroot -pflow -e "DROP DATABASE IF EXISTS drupal;"
  mysql -uroot -pflow -e "CREATE DATABASE drupal;"
  mysql -uroot -pflow -e "GRANT ALL ON drupal.* TO vagrant@localhost IDENTIFIED BY 'v4gr4nt'"

  echo "Done boostrapping vm"
  touch $BOOTSTRAPPED

else
  echo "VM already boostrapped"
fi
