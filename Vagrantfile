# -*- mode: ruby -*-
# vi: set ft=ruby :
 
Vagrant.configure("2") do |config|

  config.vm.box       = 'precise32'
  config.vm.box_url = "http://files.vagrantup.com/precise32.box"

  config.vm.hostname = 'flowdistro'

	# Allow apache to write into /vagrant
  config.vm.synced_folder ".", "/vagrant", :owner => "www-data", :group => "vagrant", :mount_options => ["dmode=775","fmode=775"]
  
  # Cache APT packages outside of the vm
  config.vm.synced_folder "vagrant_setup/cache", "/var/cache/apt/archives/"

  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--memory", "1024"]
  end

  # HTTP
  config.vm.network :forwarded_port, guest: 80, host: 8080, auto_correct: true
  
  config.vm.provision :shell do |shell|
    shell.path = "vagrant_setup/config.sh"
    shell.args = site_picker('drush_config')
   end
end
