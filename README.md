# drupal-vagrant

Vagrant script to spin up a Drupal 8 VirtualBox-based VM.

## Requirements

This script uses bento/debian 8.7 image.
Use with vagrant >= 1.9.1, virtualbox >= 5.1.14 (stick to this version to avoid
update of VirtualBox guest additions).

## Getting started

Clone this repository into a subdirectory ```vagrant``` of an existing Drupal
installation, e.g. [flowconcept/drupal-project|https://github.com/flowconcept/drupal-project]:

    git clone flowconcept/drupal-vagrant vagrant

Copy ```templates/Vagrantfile``` to the root directory:

    cp vagrant/templates/Vagrantfile .

Modify the ```$config``` of the Vagrantfile to your requirements, i.e. on first
run set ```build: true```to build a box from scratch.

To create a pre-provisioned box use ```vagrant package``` on a running system,
upload it somewhere, configure ```box``` and ```box_url```, and
set ```build: false``` again.

## Configuration

For SSH agent forwarding align these configuration files.

On OSX keys without password need to be added on bash startup:

~/.bash_profile:

    # Add ssh key for ssh agent
    if [ -f ~/.ssh/keyname ]; then
        ssh-add -K ~/.ssh/keyname 2>/dev/null
    fi


Add a suitable drush config:

config/name.aliases.drushrc.php:

    'remote-host' => 'hostname',
    'remote-user' => 'root',
    'ssh-options' => '-o StrictHostKeyChecking=no',
