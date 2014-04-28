# -*- mode: ruby -*-
# vi: set ft=ruby :
 
require "./vagrant_setup/vagrant_addons/multisite/site_picker.rb"

Vagrant.configure("2") do |config|

  config.vm.box     = 'opscode-debian-7.4'
  config.vm.box_url = "http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_debian-7.4_chef-provisionerless.box"

  config.vm.hostname = 'flow'

  # Allow apache to write into /vagrant
  config.vm.synced_folder ".", "/vagrant", type: "rsync", rsync__exclude: ".git/"
  
  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--memory", "1024"]
  end

  # HTTP
  config.vm.network :forwarded_port, guest: 80, host: 8080, auto_correct: true
  config.vm.network :forwarded_port, guest: 443, host: 8443, auto_correct: true
  
  if Vagrant.has_plugin?("vagrant-vbguest")
    config.vbguest.auto_update = false
    config.vbguest.no_remote = true
  end

  if Vagrant.has_plugin?("vagrant-cachier")
    config.cache.scope = :box
    config.cache.auto_detect = true
  end

  config.vm.provision :shell, :path => "vagrant_setup/bootstrap.sh"
 
  if Vagrant.has_plugin?("vagrant-cachier")
    # Reconfigure cache buckets now that ruby has been installed
    config.cache.auto_detect = true
  end

  config.vm.provision :shell do |shell|
    shell.path = "vagrant_setup/provision.sh"
    shell.args = site_picker('drush_config')
   end
end
