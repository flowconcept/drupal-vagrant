# -*- mode: ruby -*-
# vi: set ft=ruby :

require File.dirname(__FILE__) + "/addons/utils.rb"
require File.dirname(__FILE__) + "/addons/site_picker.rb"

check_plugins


# Init $config hash with default values
$config = {
  box: "bento/debian-8.4",
  synced_folder_type: "nfs",
  memory: 1024,
  cpus: 1,
  cache: [:apt, :apt_lists, :chef, :composer, :bower, :npm, :gem],
  recipes: ["debian::default", "debian::mysql", "debian::localdev"]
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

    # Enable linked clones
    vb.linked_clone = true

    # Enable network tracing
#    vb.customize ['modifyvm', :id, '--nictrace1', 'on']
#    vb.customize ['modifyvm', :id, '--nictracefile1', 'trace.pcap']
  end

  # Synced folders
  case $config[:synced_folder_type]
    when "rsync"
      config.vm.synced_folder ".", "/vagrant", type: "rsync", rsync__exclude: [".git/", ".idea/"]
    when "nfs"
      config.vm.synced_folder ".", "/vagrant", type: "nfs", nfs_udp: false, mount_options: ["nolock,vers=3,tcp,noatime,actimeo=1"]
    when "default"
      config.vm.synced_folder ".", "/vagrant", owner: "vagrant", group: "www-data", mount_options: ["dmode=775","fmode=775"]
    else
      raise "Unknown $config_vm_synced_folder_type #{$config[:synced_folder_type]}"
  end

  # Setup cache buckets (vagrant-cachier)
  config.cache.scope = :box
  config.cache.synced_folder_opts = {
    type: :nfs,
    mount_options: ["nolock,vers=3,tcp"]
  }
  config.cache.auto_detect = false
  $config[:cache].each { |cache| config.cache.enable cache }

  # Sync VirtualBox guest additions (vagrant-vbguest)
  config.vbguest.no_remote = true

  # Fix running as tty
  config.ssh.pty = false
  # Enable ssh agent forwarding
  config.ssh.forward_agent = true


  config.vm.provision :chef_solo do |chef|
    chef.version = "12.10.24"
    chef.cookbooks_path = "vagrant/chef/cookbooks"
#   chef.roles_path     = "../../chef/roles"
#   chef.add_role "db"
    $config[:recipes].each { |recipe| chef.add_recipe recipe }
    chef.json = {}
  end

  # Provision box
  config.vm.provision "shell" do |shell|
    shell.path = File.dirname(__FILE__) + "/scripts/provision.sh"
    shell.args = site_picker("drush_config")
    shell.privileged = false
   end

  # Forget provisioned site (vagrant-triggers)
  config.trigger.before [:destroy] do
    site_picker_forget
  end
end
