# edge-anomaly-detection

## Configure Dependencies
```
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash
sudo mv kustomize /usr/local/bin/
git clone https://github.com/tosin2013/sno-quickstarts.git
cd sno-quickstarts/gitops
./deploy.sh
cd ~
git clone https://github.com/tosin2013/edge-anomaly-detection.git
cd $HOME/edge-anomaly-detection
oc apply -k clusters/overlays/rhdp-4.12
```