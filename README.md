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
## ADD External secrets 
# https://github.com/tosin2013/external-secrets-manager
helm install charts/external-secrets --generate-name
oc apply -k clusters/overlays/rhdp-4.12
helm install charts/edge-datalake --dry-run --generate-name
```