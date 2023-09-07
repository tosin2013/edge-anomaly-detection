#!/bin/bash

# on demo.redhat.com INVENTORY can be GUID
read -p "Enter your Inventory Name [default: bastion]: " INVENTORY
INVENTORY=${INVENTORY:-bastion}

# Set cluster user and host
control_user=lab-user  #${USER}
control_host=$(hostname -I | awk '{print $1}')

# Set the IP address
IP_ADDRESS=$(hostname -I | awk '{print $1}')

# Check for the external-secrets-manager directory
if [ ! -d "$HOME/external-secrets-manager" ]; then
  echo "ERROR: external-secrets-manager directory not found"
  exit 1
fi

cd $HOME/external-secrets-manager

cp -avi inventories/controller/ inventories/${INVENTORY}

cat >~/.ansible-navigator.yml<<EOF
---
ansible-navigator:
  ansible:
    inventory:
      entries:
      - $HOME/external-secrets-manager/inventories/${INVENTORY}
      - $HOME/external-secrets-manager/vars
  execution-environment:
    container-engine: podman
    enabled: true
    environment-variables:
      pass:
      - USER
    image: quay.io/takinosh/external-secrets-manager:v1.0.0
    pull:
      policy: missing
  logging:
    append: true
    file: /tmp/navigator/ansible-navigator.log
    level: debug
  playbook-artifact:
    enable: false
EOF


echo "[control]" > inventories/${INVENTORY}/hosts
echo "control ansible_host=${control_host} ansible_user=${control_user}" >> inventories/${INVENTORY}/hosts

if [ ! -f ~/.ssh/id_rsa ]; then
  ssh-keygen -f ~/.ssh/id_rsa -t rsa -N ''
fi

# Check if the IP address exists in the known_hosts file
if grep -q "${IP_ADDRESS}" ~/.ssh/known_hosts; then
    echo "The IP address ${IP_ADDRESS} exists in known_hosts."
else
    echo "The IP address ${IP_ADDRESS} does not exist in known_hosts."
    ssh-copy-id $sno_clusters_user@${IP_ADDRESS} # $USER
fi

echo "****************************************************************"
echo "Edit: vim inventories/${INVENTORY}/group_vars/all.yaml "
echo "*****************************************************************"