#!/bin/bash

sudo dnf -y install \
  bzip2-devel \
  libffi-devel \
  openssl-devel \
  make \
  zlib-devel \
  perl \
  ncurses-devel \
  sqlite \
  sqlite-devel \
  git \
  wget \
  curl \
  nano \
  vim \
  unzip \
  bind-utils \
  tar \
  util-linux-user \
  gcc \
  podman \
  skopeo \
  buildah \
  crun \
  slirp4netns \
  fuse-overlayfs \
  containernetworking-plugins \
  iputils \
  iproute

sudo dnf -y groupinstall "Development Tools"

#==============================================================================
# Non-root podman hacks
sudo chmod 4755 /usr/bin/newgidmap
sudo chmod 4755 /usr/bin/newuidmap

sudo dnf reinstall -yq shadow-utils

cat > /tmp/xdg_runtime_dir.sh <<EOF
export XDG_RUNTIME_DIR="\$HOME/.run/containers"
EOF

sudo mv /tmp/xdg_runtime_dir.sh /etc/profile.d/xdg_runtime_dir.sh
sudo chmod a+rx /etc/profile.d/xdg_runtime_dir.sh
sudo cp /etc/profile.d/xdg_runtime_dir.sh /etc/profile.d/xdg_runtime_dir.zsh


cat > /tmp/ping_group_range.conf <<EOF
net.ipv4.ping_group_range=0 2000000
EOF
sudo mv /tmp/ping_group_range.conf /etc/sysctl.d/ping_group_range.conf

sudo sysctl --system

ansible-galaxy collection install kubernetes.core
python3 -m pip install kubernetes

curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash
sudo mv kustomize /usr/local/bin/