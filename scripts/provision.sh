#!/usr/bin/env bash

SITE="$1"

# Sync configuration files
sudo rsync --keep-dirlinks --recursive --perms --owner --group /vagrant/vagrant/config/root/ /
sudo chown -R vagrant /home/vagrant
sudo adduser vagrant www-data

# Prepare public files directory
if [ ! -d /public ]; then
  sudo mkdir /public
  sudo chmod g+w /public
  sudo chown -R www-data:www-data /public
fi

cd /vagrant

# Install composer packages
composer install --working-dir=/vagrant --no-interaction --no-progress

# Install project-specific packages
npm -s install
# Rebuild node packages to avoid problems with differing npm versions inside and
# outside of vm
npm -s rebuild

# Build assets
bower install
COMPASS_PRODUCTION=true gulp build

# Configure drupal 'localhost' if multisite project
if [ -n "$SITE" ]; then
  echo "<?php
  // Generated by vagrant/provision.sh
  \$sites['localhost'] = '$SITE';" > /vagrant/htdocs/sites/sites-local.php

  if [ -d "/vagrant/htdocs/sites/$SITE" ]; then
    cp /vagrant/htdocs/sites/default/settings.local.php "/vagrant/htdocs/sites/$SITE/settings.local.php"
  fi
fi

# Sync staging to development environment if @vagrant site aliases exist,
# otherwise install Drupal.
if [ -n "`drush sa | grep vagrant`" ]
  then
    PUBLIC=`drush dd @vagrant.dev:%files`
    if [ ! -e "$PUBLIC" ]; then
      sudo ln -s /public ${PUBLIC}
    fi

    drush --yes @vagrant.dev sql-drop
    drush --yes sql-sync @vagrant.staging @vagrant.dev
    sudo chown -R vagrant /public
    drush --yes rsync @vagrant.staging:%files @vagrant.dev:%files
    sudo chown -R www-data:www-data /public
    sudo chmod -R g+w /public
    drush --yes @vagrant.dev updb
    drush @vagrant.dev cr
  else
    echo "Drupal not installed yet or vagrant.aliases.drushrc.php is missing."
    echo ""
    echo "To install Drupal now:"
    echo "vagrant ssh"
    echo "cd /var/www/htdocs"
    echo "drush site-install --yes --account-name=flowconcept --account-mail=technik@flowconcept.de --account-pass=flow --site-name="Drupal" --site-mail=technik@flowconcept.de standard"
    echo ""
fi

echo "Done provisioning site $SITE"
