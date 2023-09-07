# edge-anomaly-detection

## Configure Dependencies

*Quick Start *
```
curl -sSL https://raw.githubusercontent.com/tosin2013/edge-anomaly-detection/main/hack/setup-bastion.sh | bash -
```

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


git clone https://github.com/tosin2013/sno-quickstarts.git
cd sno-quickstarts/gitops
./deploy.sh
cd ~
git clone https://github.com/tosin2013/edge-anomaly-detection.git
cd $HOME/edge-anomaly-detection
## ADD External secrets 
# https://github.com/tosin2013/external-secrets-manager
oc apply -k clusters/overlays/rhdp-4.12

oc new-project edge-datalake
helm install charts/edge-datalake --generate-name  --namespace edge-datalake
helm template charts/external-secrets --generate-name | oc apply -f -

```