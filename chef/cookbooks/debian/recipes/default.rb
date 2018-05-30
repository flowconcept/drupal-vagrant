if !File.exists?('/root/.default_recipe_installed')

  # --- update sources list
  file_content = "deb http://httpredir.debian.org/debian stretch main non-free
deb-src http://httpredir.debian.org/debian stretch main non-free\n
deb http://security.debian.org/ stretch/updates main non-free
deb-src http://security.debian.org/ stretch/updates main non-free\n
# jessie-updates, previously known as 'volatile'
deb http://httpredir.debian.org/debian stretch-updates main non-free
deb-src http://httpredir.debian.org/debian stretch-updates main non-free
deb https://deb.nodesource.com/node_9.x jessie main
deb-src https://deb.nodesource.com/node_9.x jessie main\n"

  file "/etc/apt/sources.list" do
    content file_content
    mode "0644"
  end

  bash 'install transport-https' do
    code 'apt-get install apt-transport-https'
  end

  bash 'install nodesource gpg key' do
    code 'curl --silent https://deb.nodesource.com/gpgkey/nodesource.gpg.key | sudo apt-key add -'
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

  package 'libapache2-mpm-itk' do
    action :install
  end

  package 'libapache2-mod-fcgid' do
    action :install
  end

  #package 'libapache2-mod-php7.0' do
  #  action :install
  #end

  bash 'enable apache2 modules' do
    code 'a2enmod actions alias expires fcgid headers rewrite deflate ssl proxy_fcgi'
  end

  package 'imagemagick' do
    action :install
  end

  package 'php-cli' do
    action :install
  end

  package 'php7.0-fpm' do
    action :install
  end

  package 'php-apcu' do
    action :install
  end

  package 'php-pear' do
    action :install
  end

  package 'php-curl' do
    action :install
  end

  package 'php-gd' do
    action :install
  end

  package 'php-imagick' do
    action :install
  end

  package 'php-mcrypt' do
    action :install
  end

  package 'php-mysql' do
    action :install
  end

  package 'php-dev' do
    action :install
  end

  package 'php-zip' do
    action :install
  end

  package 'php-twig' do
    action :install
  end

  package 'php-ssh2' do
    action :install
  end

  bash 'install node' do
    code 'apt-get install nodejs'
  end

  package 'nodejs' do
    action :install
  end

  bash 'configure global node package location' do
    code <<-EOH
      sudo -u vagrant -i npm config set depth 0
      sudo -u vagrant -i npm config set prefix "/home/vagrant/.npm-packages"
      sudo -u vagrant -i echo "export PATH=/home/vagrant/.npm-packages/bin:$PATH" >> /home/vagrant/.profile
      sudo -u vagrant -i echo "export PATH=/home/vagrant/.npm-packages/bin:$PATH" >> /home/vagrant/.bashrc
      sudo -u vagrant -i echo "export NODE_PATH=$NODE_PATH:/home/vagrant/.npm-packages/lib/node_modules" >> /home/vagrant/.bashrc
    EOH
  end

  bash 'update npm' do
    code 'sudo -u vagrant -i npm install -sg npm'
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
    code 'sudo -u vagrant -i npm install -sg bower gulp'
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

