#!/bin/sh

# Configure basic system without gems, npm packages, etc. that require a cachier reconfiguration.

BOOTSTRAPPED="/etc/vagrant-bootstrapped"
if [ ! -e $BOOTSTRAPPED ]; then

	# Update home directory:
	usermod -d /var/www/ vagrant

	apt-get -y update

	# build toolchain
	apt-get install -y curl build-essential git-core

	# apache
	apt-get install -y apache2 apache2-mpm-prefork

	# mysql
	DEBIAN_FRONTEND=noninteractive  apt-get install -y mysql-server mysql-client
	mysqladmin -u root password flow

	# PHP
	apt-get install -y php5 php5-dev php-pear
	pear config-set php_ini /etc/php5/apache2/php.ini
	pecl config-set php_ini /etc/php5/apache2/php.ini

	# Drush
	apt-get install -y drush

	# Ruby
	apt-get install -y ruby ruby-dev

	# Vim
	apt-get install -y vim

	# Link /var/www
	rm -rf /var/www/
	ln -s /vagrant /var/www
	mkdir -p /var/www/private
	chown -R www-data:www-data /var/www

	# SSH config
	sudo -u vagrant -H cp /vagrant/vagrant_setup/ssh/* /home/vagrant/.ssh/
	sudo -u vagrant -H chmod 740 /home/vagrant
	sudo -u vagrant -H chmod 740 /home/vagrant/.ssh
	sudo -u vagrant -H chmod 600 /home/vagrant/.ssh/id_rsa
	sudo -u vagrant -H chmod 740 /home/vagrant/.ssh/authorized_keys

	# Sync configuration files (done again in config.sh)
	rsync --keep-dirlinks -recursive --perms --owner --group /vagrant/vagrant_setup/root/ /
  chown -R vagrant /home/vagrant

	# Fix apache lock dir
	chown -R vagrant /var/lock/apache2

  # Enable apache modules
	a2enmod rewrite
	a2enmod ssl

	# Install/enable php extensions
	apt-get install -y php5-curl php5-gd php5-mcrypt php5-mysql php5-xdebug
	pecl install uploadprogress

	#echo `find /usr/lib/php5/ | grep xdebug.so | awk '{print "\nzend_extension = " $1 "\n"}'` >> /etc/php5/conf.d/20-xdebug.ini
	#echo `find /usr/lib/php5/ | grep uploadprogress.so | awk '{print "\nextension = " $1}'` >> /etc/php5/apache2/php.ini

	a2dissite default
	a2ensite vagrant

	# Restart apache
	/etc/init.d/apache2 restart

	# Create empty database
	mysql -uroot -pflow -e "DROP DATABASE IF EXISTS drupal;"
	mysql -uroot -pflow -e "CREATE DATABASE drupal;"
	mysql -uroot -pflow -e "GRANT ALL ON drupal.* TO vagrant@localhost IDENTIFIED BY 'grant'"

	echo "Done boostrapping vm"
	touch $BOOTSTRAPPED

else
	echo "VM already boostrapped"
fi
