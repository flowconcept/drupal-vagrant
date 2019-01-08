# -*- mode: ruby -*-
# vi: set ft=ruby :
VAGRANTFILE_API_VERSION = '2'
Vagrant.require_version '>= 1.8.3'

require File.dirname(__FILE__) + "/addons/utils.rb"
require File.dirname(__FILE__) + "/addons/site_picker.rb"

# Init defaults
$config = {
  build: true,
  build_box: "bento/debian-9.4",
  synced_folder_type: "nfs",
  memory: 2048,
  cpus: 1,
  cache: [:apt, :apt_lists, :chef, :composer, :bower, :npm, :gem],
  recipes: ["debian::default", "debian::mysql", "debian::localdev"]
}.merge($config || {})


check_plugins($config[:build])


Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  if $config[:build]
    config.vm.box     = $config[:build_box]
  else
    config.vm.box     = $config[:box]
    config.vm.box_url = $config[:box_url]
  end

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

    # Enable linked clone when building box
    if $config[:build] and Vagrant::VERSION =~ /^1.8/
      vb.linked_clone = true
    end

    # Enable network tracing
    #vb.customize ['modifyvm', :id, '--nictrace1', 'on']
    #vb.customize ['modifyvm', :id, '--nictracefile1', 'trace.pcap']
  end

  # Synced folders
  case $config[:synced_folder_type]
    when "rsync"
      config.vm.synced_folder ".", "/vagrant", type: "rsync", rsync__exclude: [".git/", ".idea/"]
    when "nfs"
      config.vm.synced_folder ".", "/vagrant", type: "nfs", nfs_udp: false, nfs: true, mount_options: ["nolock,vers=3,tcp,noatime,actimeo=1"]
    when "default"
      config.vm.synced_folder ".", "/vagrant", owner: "vagrant", group: "www-data", mount_options: ["dmode=775","fmode=775"]
    else
      raise "Unknown $config_vm_synced_folder_type #{$config[:synced_folder_type]}"
  end

  # Setup cache buckets when building box (vagrant-cachier)
  if $config[:build]
    config.cache.scope = :box
    config.cache.synced_folder_opts = {
      type: :nfs,
      mount_options: ["nolock,vers=3,tcp"]
    }
    config.cache.auto_detect = false
    $config[:cache].each { |cache| config.cache.enable cache }
  end

  # Sync VirtualBox guest additions (vagrant-vbguest)
  config.vbguest.no_remote = true

  # Enable ssh agent forwarding
  config.ssh.forward_agent = true

  # Insert custom ssh keys
  config.ssh.insert_key = false
  config.ssh.private_key_path = [
    File.dirname(__FILE__) + "/keys/private",
    "~/.vagrant.d/insecure_private_key"
  ]
  config.vm.provision "file", source: File.dirname(__FILE__) + "/keys/public", destination: "~/.ssh/authorized_keys"
  config.vm.provision "shell", inline: <<-EOC
    sudo sed -i -e "\\#PasswordAuthentication yes# s#PasswordAuthentication yes#PasswordAuthentication no#g" /etc/ssh/sshd_config
    sudo service ssh restart
  EOC

  config.vm.provision :chef_solo do |chef|
    chef.cookbooks_path = "vagrant/chef/cookbooks"
#   chef.roles_path     = "../../chef/roles"
#   chef.add_role "db"
    $config[:recipes].each { |recipe| chef.add_recipe recipe }
    chef.json = {}
  end

  ssh_pub_key = File.readlines("#{Dir.home}/.ssh/id_rsa.pub").first.strip
  config.vm.provision 'shell', inline: "echo #{ssh_pub_key} >> /home/vagrant/.ssh/authorized_keys", privileged: false
  config.ssh.insert_key = false

  config.vm.provision "shell" do |s|
    ssh_prv_key = File.read("#{Dir.home}/.ssh/id_rsa")
    ssh_pub_key = File.readlines("#{Dir.home}/.ssh/id_rsa.pub").first.strip
    s.inline = <<-SHELL
      echo Provisioning public ssh key...
      [ -e /home/vagrant/.ssh/id_rsa.pub ] && rm /home/vagrant/.ssh/id_rsa.pub
      touch /home/vagrant/.ssh/id_rsa.pub
      echo "#{ssh_pub_key}" >> /home/vagrant/.ssh/id_rsa.pub

      echo Provisioning private ssh key...
      [ -e /home/vagrant/.ssh/id_rsa ] && rm /home/vagrant/.ssh/id_rsa
      touch /home/vagrant/.ssh/id_rsa
      echo "#{ssh_prv_key}" >> /home/vagrant/.ssh/id_rsa
      chmod 400 /home/vagrant/.ssh/id_rsa

      echo Provisioning of ssh keys completed [Success].
    SHELL
  end

  # Provision box
  config.vm.provision "shell" do |shell|
    shell.path = File.dirname(__FILE__) + "/scripts/provision.sh"
    shell.args = site_picker("config")
    shell.privileged = false
   end

  # Forget provisioned site (vagrant-triggers)
  config.trigger.before [:destroy] do
    site_picker_forget
  end
end
