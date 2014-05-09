# -*- mode: ruby -*-
# vi: set ft=ruby :
 
require "./vagrant_setup/vagrant_addons/multisite/site_picker.rb"

Vagrant.configure("2") do |config|

  config.vm.box      = "opscode-debian-7.4"
  config.vm.box_url  = "http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_debian-7.4_chef-provisionerless.box"
  config.vm.hostname = 'flow-vm'

  # Networks
  config.vm.network "forwarded_port", guest: 80, host: 8080, auto_correct: true
  config.vm.network "forwarded_port", guest: 443, host: 8443, auto_correct: true

  # Provider configuration
  config.vm.provider "virtualbox" do |vb|
    vb.memory = 1024
    vb.cpus = 2
    #vb.customize ["modifyvm", :id, "--option", "value"]
  end

  # Synced folders
  #config.vm.synced_folder ".", "/vagrant", :owner => "www-data", :group => "vagrant", :mount_options => ["dmode=775","fmode=775"]
  config.vm.synced_folder ".", "/vagrant", type: "rsync", rsync__exclude: [".git/", ".idea/"]
  
  # Setup cache buckets
  if Vagrant.has_plugin?("vagrant-cachier")
    config.cache.scope = :box
    config.cache.auto_detect = true
  end

  # Sync VirtualBox guest additions
  if Vagrant.has_plugin?("vagrant-vbguest")
    config.vbguest.no_remote = true
  end

  # Fix running as tty
  config.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"

  # Bootstrap box
  config.vm.provision "shell", path: "vagrant_setup/bootstrap.sh"
 
  # Redetect cache buckets for e.g. ruby gems
  if Vagrant.has_plugin?("vagrant-cachier")
    config.cache.auto_detect = true
  end

  config.vm.provision "shell" do |shell|
    shell.path = "vagrant_setup/provision.sh"
    shell.args = site_picker("drush_config")
   end
end
