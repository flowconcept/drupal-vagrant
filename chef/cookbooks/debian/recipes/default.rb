if !File.exists?('/root/.default_recipe_installed')

  # --- update sources list
  file_content = "deb http://httpredir.debian.org/debian jessie main non-free
deb-src http://httpredir.debian.org/debian jessie main non-free\n
deb http://security.debian.org/ jessie/updates main non-free
deb-src http://security.debian.org/ jessie/updates main non-free\n
# jessie-updates, previously known as 'volatile'
deb http://httpredir.debian.org/debian jessie-updates main non-free
deb-src http://httpredir.debian.org/debian jessie-updates main non-free\n"

  file "/etc/apt/sources.list" do
    content file_content
    mode "0644"
  end

  bash 'update apt cache' do
    code 'apt-get update'
  end

  bash 'upgrade packages' do
    code 'DEBIAN_FRONTEND=noninteractive apt-get -y upgrade'
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

  bash 'configure global node package location' do
    code <<-EOH
      sudo -u vagrant -i npm config set prefix "/home/vagrant/.npm-packages"
      sudo -u vagrant -i echo "export PATH=/home/vagrant/.npm-packages/bin:$PATH" >> /home/vagrant/.profile
      sudo -u vagrant -i echo "export PATH=/home/vagrant/.npm-packages/bin:$PATH" >> /home/vagrant/.bashrc
      sudo -u vagrant -i echo "export NODE_PATH=$NODE_PATH:/home/vagrant/.npm-packages/lib/node_modules" >> /home/vagrant/.bashrc
    EOH
  end

  bash 'update npm' do
    code 'sudo -u vagrant -i npm install -sg npm@3.x-latest'
  end

  bash 'regenerate ssh host keys' do
    code <<-EOH
      rm -rf /etc/ssh/ssh_host_*
      dpkg-reconfigure openssh-server
      touch /root/.ssh_host_keys_regenerated
    EOH
    only_if { !File.exists?('/root/.ssh_host_keys_regenerated') }
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

  bash 'install global node packages' do
    code 'sudo -u vagrant -i npm install -sg bower gulp yo'
  end

  bash 'install composer' do
    code <<-EOH
      curl -sS https://getcomposer.org/installer | php
      mv composer.phar /usr/local/bin/composer
      chmod +x /usr/local/bin/composer
      ln -s /usr/local/bin/composer /usr/bin/composer
    EOH
    only_if { !File.exists?('/usr/local/bin/composer') }
  end

  bash 'install drush' do
    code <<-EOH
      curl -sS http://files.drush.org/drush.phar -o drush.phar
      mv drush.phar /usr/local/bin/drush
      chmod +x /usr/local/bin/drush
    EOH
    only_if { !File.exists?('/usr/local/bin/drush') }
  end

  bash 'install drupal console' do
    code <<-EOH
      curl -sS https://drupalconsole.com/installer -L -o drupal.phar
      mv drupal.phar /usr/local/bin/drupal
      chmod +x /usr/local/bin/drupal
      sudo -u vagrant -i drupal init
    EOH
    only_if { !File.exists?('/usr/local/bin/drupal') }
  end

  service 'apache2' do
    action :restart
  end

  bash 'set marker' do
    code 'touch /root/.default_recipe_installed'
  end

end

