if !File.exists?('/root/.default_recipe_installed')

  # --- update sources list
  file_content = "deb http://ftp.de.debian.org/debian/ jessie main non-free
  deb-src http://ftp.de.debian.org/debian/ jessie main non-free\n
  deb http://security.debian.org/ jessie/updates main non-free
  deb-src http://security.debian.org/ jessie/updates main non-free\n
  # jessie-updates, previously known as 'volatile'
  deb http://ftp.de.debian.org/debian/ jessie-updates main non-free
  deb-src http://ftp.de.debian.org/debian/ jessie-updates main non-free"

  file "/etc/apt/sources.list" do
    content file_content
    mode "0644"
  end

  bash 'update apt cache' do
    code 'apt-get update'
  end

  bash 'upgrade packages' do
    code 'apt-get -y upgrade'
  end

  # --- Install packages we need ---
  package 'bsdutils' do
    action :install
  end

  package 'dialog' do
    action :install
  end

  package 'apt-utils' do
    action :install
  end

  package 'logrotate' do
    action :install
  end

  package 'postfix' do
    action :install
  end

  package 'byobu' do
    action :install
  end

  package 'git-core' do
    action :install
  end

  package 'less' do
    action :install
  end

  package 'poppler-utils' do
    action :install
  end

  package 'vim' do
    action :install
  end

  package 'ntp' do
    action :install
  end

  package 'apache2' do
    action :install
  end

  package 'apache2-mpm-worker' do
    action :install
  end

  package 'libapache2-mod-fastcgi' do
    action :install
  end

  bash 'enable apache2 modules' do
    code 'a2enmod actions alias expires fastcgi headers rewrite deflate ssl'
  end

  package 'imagemagick' do
    action :install
  end

  package 'php5-cli' do
    action :install
  end

  package 'php5-fpm' do
    action :install
  end

  package 'php-apc' do
    action :install
  end

  package 'php-pear' do
    action :install
  end

  package 'php5-curl' do
    action :install
  end

  package 'php5-gd' do
    action :install
  end

  package 'php5-imagick' do
    action :install
  end

  package 'php5-mcrypt' do
    action :install
  end

  package 'php5-mysql' do
    action :install
  end

  package 'php5-dev' do
    action :install
  end

  package 'php5-twig' do
    action :install
  end

  package 'libssh2-php' do
    action :install
  end

  bash 'install node' do
    code 'curl -sL https://deb.nodesource.com/setup_4.x | bash -'
  end

  package 'nodejs' do
    action :install
  end

  bash 'npm update' do
    code 'npm install -g npm@3.x-latest'
  end

  bash 'regenerate ssh host keys' do
    code 'rm -rf /etc/ssh/ssh_host_* && dpkg-reconfigure openssh-server && touch /root/.ssh_host_keys_regenerated'
    only_if do
      !File.exists?('/root/.vimvim_host_keys_regenerated')
    end
  end

  # --- Deploy a configuration file ---
  # For longer files, when using 'content "..."' becomes too
  # cumbersome, we can resort to deploying separate files:
  # cookbook_file '/etc/apache2/apache2.conf'
  # This will copy cookbooks/op/files/default/apache2.conf (which
  # you'll have to create yourself) into place. Whenever you edit
  # that file, simply run "./deploy.sh" to copy it to the server.

  execute 'update-tzdata' do
    command 'dpkg-reconfigure -f noninteractive tzdata'
  end

  file '/etc/timezone' do
    owner "root"
    group "root"
    mode "00644"
    content "Europe/Berlin"
    notifies :run, "execute[update-tzdata]"
  end

  bash 'composer_install' do
    code <<-EOH
      curl -sS https://getcomposer.org/installer | php
      mv composer.phar /usr/local/bin/composer
      ln -s /usr/local/bin/composer /usr/bin/composer
    EOH
    not_if { ::File.exists?('/usr/local/bin/composer') }
  end

  bash 'drush_install' do
    code <<-EOH
      git clone -b master https://github.com/drush-ops/drush.git /usr/local/src/drush
      ln -s /usr/local/src/drush/drush /usr/bin/drush
      ln -s /usr/local/src/drush/drush.complete.sh /etc/bash_completion.d/drush.complete.sh
      cd /usr/local/src/drush
      composer install
    EOH
  end

  bash 'console_install' do
    code <<-EOH
      curl -LSs http://drupalconsole.com/installer | php
      mv console.phar /usr/local/bin/drupal
      ln -s /usr/local/bin/drupal /usr/bin/drupal
    EOH
    not_if { ::File.exists?('/usr/local/bin/drupal') }
  end

  bash 'bower_install' do
    code 'npm install -g bower'
  end

  bash 'gulp_install' do
    code 'npm install -g gulp'
  end

  service 'apache2' do
    action :restart
  end

  bash 'set marker' do
    code 'touch /root/.default_recipe_installed'
  end

end

