#!/bin/sh

SITE="$1"

# Sync configuration files
rsync --keep-dirlinks -recursive --perms --owner --group /vagrant/vagrant/config/root/ /
chown -R vagrant /home/vagrant

# Prepare public files directory
if [ ! -d /public ]; then
  mkdir /public
  chown -R www-data:www-data /public
fi

# Run composer install
sudo -u vagrant -H composer install -d /vagrant -n

cd /vagrant
# Install packages, rebuild npm packages to avoid problems with already
sudo -u vagrant -H npm install
sudo -u vagrant -H npm rebuild
sudo -u vagrant -H bower install

# Build css
sudo -u vagrant -H gulp build

# Tell drupal which site to use
if [ -n "$SITE" ]; then
  echo "<?php
  // Generated by vagrant provision.sh
  \$sites['localhost'] = '$SITE';" > /var/www/htdocs/sites/sites-local.php
  if [ -d "/var/www/htdocs/sites/$SITE" ]; then
    cp /var/www/htdocs/sites/default/settings.local.php "/var/www/htdocs/sites/$SITE/settings.local.php"
  fi
fi

# Sync staging to development environment if @vagrant site aliases exist.
# Otherwise install Drupal.
if [ -n "`sudo -u vagrant -H drush sa | grep vagrant`" ]
  then
    PUBLIC=`sudo -u vagrant -H drush dd @vagrant.dev:%files`
    if [ ! -e "$PUBLIC" ]; then
      ln -s /public ${PUBLIC}
    fi
    sudo -u vagrant -H drush --yes @vagrant.dev sql-drop
    sudo -u vagrant -H drush --yes sql-sync @vagrant.staging @vagrant.dev
    chown -R vagrant /public
    sudo -u vagrant -H drush --yes rsync @vagrant.staging:%files @vagrant.dev:%files
    chown -R www-data:www-data /public
    sudo -u vagrant -H drush @vagrant.dev cr
  else
    echo "Drupal not installed yet or vagrant.aliases.drushrc.php is missing."
    echo ""
    echo "To install Drupal now:"
    echo "vagrant ssh"
    echo "cd /var/www/htdocs"
    echo "drush site-install --db-url=mysql://vagrant:v4gr4nt@localhost/drupal --account-name=flowconcept --account-mail=info@flowconcept.de --account-pass=flow --site-name=flow --site-mail=info@flowconcept.de standard"
    echo ""
fi

echo "Done provisioning site $SITE"
