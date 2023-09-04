# edge-anomaly-detection

## Configure Dependencies
```
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash
sudo mv kustomize /usr/local/bin/

curl -OL https://raw.githubusercontent.com/tosin2013/openshift-4-deployment-notes/master/aws/configure-aws-cli.sh
chmod +x configure-aws-cli.sh 

aws s3 mb s3://edge-anomaly-detection-$GUID
edge-anomaly-detection-lkl7z

sudo yum install ansible-core -y
ansible-galaxy collection install kubernetes.core
python3 -m pip install kubernetes


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