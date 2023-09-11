#!/bin/bash

# Set a default repo name if not provided
#REPO_NAME=${REPO_NAME:-tosin2013/external-secrets-manager}

if [[ -s ~/.vault_password ]]; then
    echo "The file contains information."
else
    curl -OL https://gist.githubusercontent.com/tosin2013/022841d90216df8617244ab6d6aceaf8/raw/92400b9e459351d204feb67b985c08df6477d7fa/ansible_vault_setup.sh
    chmod +x ansible_vault_setup.sh
    ./ansible_vault_setup.sh
fi

if [ ! -f $HOME/configure-aws-cli.sh ];
then
  # Prompt the user for AWS variables
  read -p "Enter your AWS Access Key ID: " aws_access_key_id
  read -p "Enter your AWS Secret Access Key: " aws_secret_access_key
  read -p "Enter your AWS Region: " aws_region
  curl -OL https://raw.githubusercontent.com/tosin2013/openshift-4-deployment-notes/master/aws/configure-aws-cli.sh
  chmod +x configure-aws-cli.sh 
  ./configure-aws-cli.sh  -i ${aws_access_key_id} ${aws_secret_access_key} ${aws_region}
  aws s3 mb s3://edge-anomaly-detection-$GUID
fi

# Ensure Git is installed
echo "Installing Git..."
sudo dnf install -yq git
if ! yq -v  &> /dev/null
then
    VERSION=v4.34.1
    BINARY=yq_linux_amd64
    sudo wget https://github.com/mikefarah/yq/releases/download/${VERSION}/${BINARY} -O /usr/bin/yq &&\
    sudo chmod +x /usr/bin/yq
fi



# Check if the repository is already cloned
if [ -d "$HOME/edge-anomaly-detection" ]; then
  cd $HOME/edge-anomaly-detection
  git config pull.rebase false
  git pull
else
  cd $HOME
  echo "Cloning from github.com/edge-anomaly-detection ..."
  git clone https://github.com/tosin2013/edge-anomaly-detection.git
  cd $HOME/edge-anomaly-detection
fi


# Install System Packages
./hack/partial-rpm-packages.sh

# Run the configuration script to setup the bastion host with:
# - Python 3.9
# - Ansible
# - Ansible Navigator
# - Pip modules
./hack/partial-python39-setup.sh

# Install OCP CLI Tools
if [ ! -f /usr/bin/oc ]; then
  ./hack/partial-setup-ocp-cli.sh
fi


# Check if the repository is already cloned
if [ -d "$HOME/external-secrets-manager" ]; then
  cd $HOME/external-secrets-manager
  git config pull.rebase false
  git pull
else
  cd $HOME
  echo "Cloning from github.com/external-secrets-manager ..."
  git clone https://github.com/tosin2013/external-secrets-manager.git
  cd $HOME/external-secrets-manager
fi


curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash
sudo mv kustomize /usr/local/bin/

cd $HOME


ansible-galaxy collection install kubernetes.core
python3 -m pip install kubernetes

git clone https://github.com/tosin2013/sno-quickstarts.git
cd sno-quickstarts/gitops
./deploy.sh


$HOME/edge-anomaly-detection/hack/create-new-env-config.sh
cd $HOME/external-secrets-manager/
ansible-navigator run install-vault.yaml  --extra-vars "install_vault=true" \
 --vault-password-file $HOME/.vault_password -m stdout || exit $?

cat >vars/values-secret.yaml<<EOF
version: "2.0"
#main:
#  git:
#    Normally valuesDirectoryURL is auto-calculated by the install chart
#
#    People actively working on the pattern might like to specify an alternate
#    location so that they don't accidentally commit theire cluster details to
#    the main branch
#
#    Beware that ArgoCD often requires additional help to refelect any changes to
#     the file located here
#
#    valuesDirectoryURL: https://github.com/beekhof/patterns/raw/main
  
secrets:

  - name: aws
    fields:
    - name: aws_access_key_id
      ini_file: /home/$USER/.aws/credentials
      ini_key: aws_access_key_id
    - name: aws_secret_access_key
      ini_file:  /home/$USER/.aws/credentials
      ini_key: aws_secret_access_key
EOF

ansible-navigator run push-secrets.yaml --extra-vars "vault_push_secrets=true"   --extra-vars "vault_secrets_init=true" \
--vault-password-file $HOME/.vault_password -m stdout  || exit $?

cd $HOME/edge-anomaly-detection
oc create -k clusters/overlays/rhdp-4.12 

oc new-project edge-datalake
helm install charts/edge-datalake --generate-name  --namespace edge-datalake
helm template charts/external-secrets --generate-name | oc apply -f -