#!/bin/bash


set -x
CHECKLOGGINGUSER=$(whoami)
if [ ${CHECKLOGGINGUSER} == "root" ];
then 
  echo "login as sudo user to run script."
  echo "You are currently logged in as root"
  exit 1
fi

if cat /etc/redhat-release  | grep "Red Hat Enterprise Linux release 8.[0-9]" > /dev/null 2>&1; then
    echo "RHEL 8 is supported"
else
    echo "RHEL 8 is not supported"
    exit 1
fi


read -p "Would you like to register the system? (y/n): " register_system

if [ "$register_system" == "y" ]; then
  sudo subscription-manager register
  sudo subscription-manager refresh
  sudo subscription-manager attach --auto
  sudo subscription-manager repos --enable=rhel-8-for-x86_64-appstream-rpms --enable=rhel-8-for-x86_64-baseos-rpms
fi

sudo dnf install git vim unzip wget bind-utils tar -y 
sudo dnf install ncurses-devel curl -y
curl 'https://vim-bootstrap.com/generate.vim' --data 'editor=vim&langs=javascript&langs=go&langs=html&langs=ruby&langs=python' > ~/.vimrc


if [ ! -f $HOME/edge-anomaly-detection ]; then 
    git clone https://github.com/tosin2013/edge-anomaly-detection.git
    cd edge-anomaly-detection
    ./hack/setup-bastion.sh
fi 