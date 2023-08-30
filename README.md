# edge-anomaly-detection

## Configure Dependencies
```
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash

sudo yum install ansible-core -y
ansible-galaxy collection install kubernetes.core
/usr/bin/python3.11 -m ensurepip
/usr/bin/python3.11 -m pip install kubernetes


sudo mv kustomize /usr/local/bin/
git clone https://github.com/tosin2013/sno-quickstarts.git
cd sno-quickstarts/gitops
./deploy.sh
cd ~
git clone https://github.com/tosin2013/edge-anomaly-detection.git
cd $HOME/edge-anomaly-detection
oc apply -f components/argocd/apps/overlays/hashicorp-vault/cluster-config.yaml
ansible-playbook vault-init.yaml
helm install charts/external-secrets --generate-name
ansible-playbook -t vault_secrets_init -e pattern_dir="/home/ec2-user/edge-anomaly-detection" "${HOME}/edge-anomaly-detection/ansible/playbooks/vault/vault.yaml"

oc apply -k clusters/overlays/rhdp-4.12
```