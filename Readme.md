For SSH agent forwarding align these configuration files.

On OSX keys without password need to be added on bash startup:

~/.bash_profile:

    # Add ssh key for ssh agent
    if [ -f ~/.ssh/keyname ]; then
        ssh-add -K ~/.ssh/keyname 2>/dev/null
    fi


Add a suitable drush config:

drush_config/name.aliases.drushrc.php:

    'remote-host' => 'hostname',
    'remote-user' => 'root',
    'ssh-options' => '-o StrictHostKeyChecking=no',
