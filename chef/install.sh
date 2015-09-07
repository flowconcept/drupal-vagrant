#!/bin/bash

json="${1}"

logfile="/root/chef-solo.log"

# This runs as root on the server
chef_binary="/usr/bin/chef-solo"

# Are we on a vanilla system?
if ! test -f "$chef_binary"; then
    export DEBIAN_FRONTEND=noninteractive
    # Upgrade headlessly (this is only safe-ish on vanilla systems)
    apt-get update && apt-get install -f
    apt-get -y install curl
    curl -L https://www.opscode.com/chef/install.sh | bash
fi

# Run chef-solo on server
"$chef_binary" --config solo.rb --json-attributes "$json"