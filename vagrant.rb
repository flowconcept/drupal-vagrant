# -*- mode: ruby -*-
# vi: set ft=ruby :

require File.dirname(__FILE__) + "/addons/utils.rb"
require File.dirname(__FILE__) + "/addons/site_picker.rb"

check_plugins


# Init $config hash with default values
$config = {
  box: "opscode-debian-7.8",
  box_url: "http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_debian-7.8_chef-provisionerless.box",
  synced_folder_type: "nfs",
  memory: 1024,
  cpus: 1,
  cache: [:apt, :apt_lists, :gem]
}.merge($config || {})


Vagrant.configure("2") do |config|

  config.vm.box      = $config[:box]
  config.vm.box_url  = $config[:box_url]
  config.vm.hostname = 'flow-vm'

  # Networks
  config.vm.network "forwarded_port", guest: 80, host: 8080, auto_correct: true
  config.vm.network "forwarded_port", guest: 443, host: 8443, auto_correct: true
  config.vm.network "forwarded_port", guest: 3306, host: 8306, auto_correct: true

  # Static network for NFS
  if $config[:synced_folder_type] == "nfs"
    if Vagrant.has_plugin?("vagrant-auto_network")
      config.vm.network "private_network", :auto_network => true
    else
      config.vm.network "private_network", ip: "192.168.42.10"
    end
  end

  # Provider configuration
  config.vm.provider "virtualbox" do |vb|
    vb.memory = $config[:memory]
    vb.cpus = $config[:cpus]
  end

  # Synced folders
  case $config[:synced_folder_type]
    when "rsync"
      config.vm.synced_folder ".", "/vagrant", type: "rsync", rsync__exclude: [".git/", ".idea/"]
    when "nfs"
      config.vm.synced_folder ".", "/vagrant", type: "nfs"
    when "vboxsf"
      config.vm.synced_folder ".", "/vagrant", :owner => "vagrant", :group => "www-data", :mount_options => ["dmode=775","fmode=775"]
    else
      raise "Unknown $config_vm_synced_folder_type #{$config[:synced_folder_type]}"
  end
  
  # Setup cache buckets (vagrant-cachier)
  config.cache.scope = :box
  config.cache.auto_detect = false
  $config[:cache].each { |cache| config.cache.enable cache }
  config.cache.enable :generic, { "composer" => { :cache_dir => "/root/.composer/cache" }}

  # Sync VirtualBox guest additions (vagrant-vbguest)
  config.vbguest.no_remote = true

  # Fix running as tty
  #config.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"

  # Bootstrap box
  config.vm.provision "shell" do |shell|
    shell.path = File.dirname(__FILE__) + "/scripts/bootstrap.sh"
    shell.args = [Process.uid, Process.gid]
   end

  # Provision box
  config.vm.provision "shell" do |shell|
    shell.path = File.dirname(__FILE__) + "/scripts/provision.sh"
    shell.args = site_picker("drush_config")
   end

  # Forget provisioned site (vagrant-triggers)
  config.trigger.before [:destroy] do
    site_picker_forget
  end
end
