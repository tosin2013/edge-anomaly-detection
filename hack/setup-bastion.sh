#!/bin/bash

# Set a default repo name if not provided
REPO_NAME=${REPO_NAME:-tosin2013/external-secrets-manager}

# Ensure Git is installed
echo "Installing Git..."
sudo dnf install -yq git

# Check if the repository is already cloned
if [ -d "$HOME/external-secrets-manager" ]; then
  cd $HOME/external-secrets-manager
  git config pull.rebase false
  git pull
else
  cd $HOME
  echo "Cloning from github.com/${REPO_NAME} ..."
  git clone https://github.com/${REPO_NAME}.git
  cd $HOME/external-secrets-manager
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
./hack/partial-setup-ocp-cli.sh
