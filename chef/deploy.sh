#!/bin/bash
# Copies files to the server and runs install.

host="${1}"
file="${2}"
json_path="./targets"

if [ "$#" -eq  "0" ]; then
    echo "Usage: ./deploy.sh [user@host] [json]"
	echo 
    echo "EG: ./deploy.sh fred@192.168.1.1 web_server.json"
    echo "If no json is given it will default to solo.json"
    exit
fi
if [ "$#" -eq  "1" ]; then
  json="${json_path}/${host}.json"
fi

if [ "$#" -eq  "2" ]; then
  json="${json_path}/${file}"
fi

if [ ! -f "$json" ]; then
  echo "no chef json found"
  exit
fi

# The host key might change when we instantiate a new VM, so
# we remove (-R) the old host key from known_hosts
echo 'keygen'
ssh-keygen -R "${host#*@}" 2> /dev/null

echo 'copy chef dir & run install.sh'
tar cz . | ssh -o 'StrictHostKeyChecking no' "$host" "
rm -rf ~/chef &&
mkdir ~/chef &&
cd ~/chef &&
tar xz &&
bash install.sh $json"
