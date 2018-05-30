if !File.exists?('/root/.localdev_recipe_installed')

  package 'php-xdebug' do
    action :install
  end

  package 'nfs-client' do
    action :install
  end

  #bash 'mount flow' do
  #  code 'mkdir /www && mkdir /www/flow_vr && mount 192.168.32.1:/Users/volker/Code/flow/flow /www/flow_vr'
  #end

  # --- Set host name ---
  # Note how this is plain Ruby code, so we can define variables to
  # DRY up our code:
  hostname = 'flow-vm'

  file '/etc/hostname' do
    content "#{hostname}\n"
  end

  file '/etc/hosts' do
    content "127.0.0.1 localhost #{hostname}\n"
  end

  # Sync configuration files (again during provosioning)
  bash 'sync config' do
    code 'rsync --keep-dirlinks -recursive --perms --owner --group /vagrant/vagrant/config/root/ /'
  end

  # Link vagrant dir
  bash 'link vagrant dir' do
    code <<-EOH
    sudo rm -rf /var/www/
    sudo ln -s /vagrant /var/www
    sudo mkdir -p /var/www/private
    sudo chown -R www-data:www-data /var/www
    EOH
  end


  bash 'chown home' do
    code 'chown -R vagrant /home/vagrant'
  end

  # Fix ssh agent forwarding when using sudo
  bash 'fix ssh agent' do
    code 'echo "Defaults    env_keep += \"SSH_AUTH_SOCK\"" > /etc/sudoers.d/99_root_ssh_agent'
  end

  # Fix apache lock dir
  bash 'fix lock' do
    code 'chown -R vagrant /var/lock/apache2'
  end

  bash 'configure apache2' do
    code 'a2dissite 000-default; a2ensite vagrant'
  end

  bash 'Activate php-fpm configuration' do
    code 'sudo ln -s /etc/apache2/conf-available/php7.0-fpm.conf /etc/apache2/conf-enabled/php7.0-fpm.conf'
  end

  # Restart apache
  service 'apache2' do
    action :restart
  end

  service 'php7.0-fpm' do
    action :restart
  end

  # Create empty database
  bash 'create default db' do
    code <<-EOH
    mysql -e "DROP DATABASE IF EXISTS drupal;"
    mysql -e "CREATE DATABASE drupal;"
    mysql -e "GRANT ALL ON drupal.* TO vagrant@localhost IDENTIFIED BY 'v4gr4nt'"
    EOH
  end

  # Bash configuration
  bash '.bashrc additions' do
    code <<-EOH
    echo "alias l='ls --color=auto -lah'" >> /root/.bashrc
    echo "alias l='ls --color=auto -lah'" >> /home/vagrant/.bashrc
    echo "alias drv='drush @vagrant.dev'" >> /home/vagrant/.bashrc
    echo "if [ -f ~/.drush_bashrc ] ; then . ~/.drush_bashrc ; fi" >> /home/vagrant/.bashrc
    EOH
  end

  # Overwrite globally installed drush with version controlled by compass
  bash 'local drush' do
    code 'ln -sf /vagrant/vendor/bin/drush /usr/local/bin/drush'
  end

  bash 'set marker' do
    code 'touch /root/.localdev_recipe_installed'
  end

end
