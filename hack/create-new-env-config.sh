#!/bin/bash

# Check for CICD PIPLINE FLAG
if [ -z "$CICD_PIPELINE" ]; then
    echo "CICD_PIPELINE is not set."
    echo "Running in interactive mode."
else
    echo "CICD_PIPELINE is set to $CICD_PIPELINE."
    echo "Running in non-interactive mode."

    if [ -z "${INVENTORY}" ]; then
      echo "INVENTORY variable not found or empty. Exiting..."
      exit 1
    fi
    if [ -z "${OPENSHIFT_URL}" ]; then
      echo "OPENSHIFT_URL variable not found or empty. Exiting..."
      exit 1
    fi
    if [ -z "${OPENSHIFT_TOKEN}" ]; then
      echo "OPENSHIFT_TOKEN variable not found or empty. Exiting..."
      exit 1
    fi
fi

if [ $CICD_PIPELINE == "true" ];
then
  echo "INVENTORY is set to $INVENTORY."
  openshift_token=${OPENSHIFT_TOKEN}
  openshift_url=${OPENSHIFT_URL}
else
  # on demo.redhat.com INVENTORY can be GUID
  read -p "Enter your Inventory Name [default: bastion]: " INVENTORY
  INVENTORY=${INVENTORY:-bastion}
  # Prompt the user for the openshift_token
  read -p "Please enter your OpenShift token: " openshift_token
  # Prompt the user for the openshift_url
  read -p "Please enter your OpenShift URL: " openshift_url
fi


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

cd $HOME/external-secrets-manager/inventories/controller/

mkdir -p $HOME/external-secrets-manager/inventories/${INVENTORY}
cp -avi *  $HOME/external-secrets-manager/inventories/${INVENTORY}

openshift_app_url=$(oc whoami --show-console | sed -n 's|https://console-openshift-console.\(.*\)|\1|p')

yq eval ".openshift_token = \"$openshift_token\"" -i $HOME/external-secrets-manager/inventories/${INVENTORY}/group_vars/all.yml|| exit $?
yq eval ".openshift_url = \"$openshift_url\"" -i $HOME/external-secrets-manager/inventories/${INVENTORY}/group_vars/all.yml || exit $?
yq eval ".localClusterDomain = \"$openshift_app_url\"" -i $HOME/external-secrets-manager/inventories/${INVENTORY}/group_vars/all.yml || exit $?
yq eval ".hubClusterDomain = \"$openshift_app_url\"" -i $HOME/external-secrets-manager/inventories/${INVENTORY}/group_vars/all.yml || exit $?

echo "[control]" > inventories/${INVENTORY}/hosts
echo "control ansible_host=${control_host} ansible_user=${control_user}" >> inventories/${INVENTORY}/hosts

cd $HOME

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


if [ ! -f ~/.ssh/id_rsa ]; then
  ssh-keygen -f ~/.ssh/id_rsa -t rsa -N ''
fi

# Check if the IP address exists in the known_hosts file
if grep -q "${IP_ADDRESS}" ~/.ssh/known_hosts; then
    echo "The IP address ${IP_ADDRESS} exists in known_hosts."
else
    echo "The IP address ${IP_ADDRESS} does not exist in known_hosts."
    ssh-copy-id $control_user@${IP_ADDRESS} # $USER
fi

echo "****************************************************************"
echo "Edit: vim $HOME/external-secrets-manager/inventories/${INVENTORY}/group_vars/all.yml"
echo "*****************************************************************"