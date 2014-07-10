# -*- mode: ruby -*-
# vi: set ft=ruby :

require File.dirname(__FILE__) + "/addons/site_picker.rb"

Vagrant.configure("2") do |config|

  config.vm.box      = "opscode-debian-7.4"
  config.vm.box_url  = "http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_debian-7.4_chef-provisionerless.box"
  config.vm.hostname = 'flow-vm'

  # Networks
  config.vm.network "forwarded_port", guest: 80, host: 8080, auto_correct: true
  config.vm.network "forwarded_port", guest: 443, host: 8443, auto_correct: true

  # Setup static network for NFS
  if Vagrant.has_plugin?("vagrant-auto_network")
    config.vm.network "private_network", :auto_network => true
  else
    config.vm.network "private_network", ip: "192.168.42.10"
  end

  # Provider configuration
  config.vm.provider "virtualbox" do |vb|
    vb.memory = 1024
    #vb.cpus = 2
  end

  # Synced folders (choose one method)
  #config.vm.synced_folder ".", "/vagrant", type: "rsync", rsync__exclude: [".git/", ".idea/"]
  config.vm.synced_folder ".", "/vagrant", nfs: true
  #config.vm.synced_folder ".", "/vagrant", :owner => "vagrant", :group => "www-data", :mount_options => ["dmode=775","fmode=775"]
  
  # Setup cache buckets
  if Vagrant.has_plugin?("vagrant-cachier")
    config.cache.scope = :box
    config.cache.auto_detect = false
    config.cache.enable :apt
    config.cache.enable :apt_lists
    config.cache.enable :gem
  end

  # Sync VirtualBox guest additions
  if Vagrant.has_plugin?("vagrant-vbguest")
    config.vbguest.no_remote = true
  end

  # Fix running as tty
  #config.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"

  # Bootstrap box
  config.vm.provision "shell", path: File.dirname(__FILE__) + "/scripts/bootstrap.sh"

  # Provision box
  config.vm.provision "shell" do |shell|
    shell.path = File.dirname(__FILE__) + "/scripts/provision.sh"
    shell.args = site_picker("drush_config")
   end

  # Forget provisioned site
  if Vagrant.has_plugin?("vagrant-triggers")
    config.trigger.before [:destroy] do
      site_picker_forget
    end
  end
end
