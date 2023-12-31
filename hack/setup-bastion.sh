#!/bin/bash
set -x
# Set a default repo name if not provided
#REPO_NAME=${REPO_NAME:-tosin2013/external-secrets-manager}

if cat /etc/redhat-release  | grep "Red Hat Enterprise Linux release 8.[0-9]" > /dev/null 2>&1; then
    echo "RHEL 8 is supported"
else
    echo "RHEL 8 is not supported"
    exit 1
fi

OC_VERSION=4.14 # 4.12 or 4.14


# Check for CICD PIPLINE FLAG
if [ -z "$CICD_PIPELINE" ]; then
    echo "CICD_PIPELINE is not set."
    echo "Running in interactive mode."
elif [ "$CICD_PIPELINE" == "true" ]; then
    echo "CICD_PIPELINE is set to $CICD_PIPELINE."
    echo "Running in non-interactive mode."
    # Check if the AWS variables are defined and not empty
    if [ -z "${AWS_ACCESS_KEY_ID}" ] || [ -z "${AWS_SECRET_ACCESS_KEY}" ] || [ -z "${AWS_REGION}" ]; then
      echo "AWS variables not found or empty. Exiting..."
      exit 1
    fi
    if [ -z "${SSH_PASSWORD}" ]; then
      echo "SSH_PASSWORD variable not found or empty. Exiting..."
      exit 1
    fi
    if [ -z "${DEPLOYMENT_TYPE}" ]; then
      echo "DEPLOYMENT_TYPE variable not found or empty. Exiting..."
      exit 1
    fi
else
    echo "CICD_PIPELINE is not set."
    echo "Running in interactive mode."
fi



function wait-for-me(){
    while [[ $(oc get pods $1  -n $2 -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do
        sleep 1
    done

}

if [ -z $GUID ]; then 
     read -p "Enter GUID: " GUID
fi

if [[ -s ~/.vault_password ]]; then
    echo "The file contains information."
else
    curl -OL https://gist.githubusercontent.com/tosin2013/022841d90216df8617244ab6d6aceaf8/raw/92400b9e459351d204feb67b985c08df6477d7fa/ansible_vault_setup.sh
    chmod +x ansible_vault_setup.sh
    echo "Configuring password for Ansible Vault"
    if [ $CICD_PIPELINE == "true" ];
    then
        if [ -z "$SSH_PASSWORD" ]; then
            echo "SSH_PASSWORD enviornment variable is not set"
            exit 1
        fi
        echo "$SSH_PASSWORD" > ~/.vault_password
        sudo cp ~/.vault_password /root/.vault_password
        sudo cp ~/.vault_password /home/lab-user/.vault_password
        bash  ./ansible_vault_setup.sh
    else
        bash  ./ansible_vault_setup.sh
    fi
fi

if [ ! -f $HOME/configure-aws-cli.sh ] || [ $CICD_PIPELINE == "false" ];
then
  # Prompt the user for AWS variables
  read -p "Enter your AWS Access Key ID: " aws_access_key_id
  read -p "Enter your AWS Secret Access Key: " aws_secret_access_key
  read -p "Enter your AWS Region: " aws_region
  curl -OL https://raw.githubusercontent.com/tosin2013/openshift-4-deployment-notes/master/aws/configure-aws-cli.sh
  chmod +x configure-aws-cli.sh 
  ./configure-aws-cli.sh  -i ${aws_access_key_id} ${aws_secret_access_key} ${aws_region}
  # https://docs.aws.amazon.com/general/latest/gr/s3.html
  # s3.us-east-2.amazonaws.com
  aws s3 mb s3://edge-anomaly-detection-$GUID
elif [ ! -f $HOME/configure-aws-cli.sh ] && [ $CICD_PIPELINE == "true" ];
then
  curl -OL https://raw.githubusercontent.com/tosin2013/openshift-4-deployment-notes/master/aws/configure-aws-cli.sh
  chmod +x configure-aws-cli.sh 
  ./configure-aws-cli.sh  -i ${AWS_ACCESS_KEY_ID} ${AWS_SECRET_ACCESS_KEY} ${AWS_REGION}
  aws s3 mb s3://edge-anomaly-detection-$GUID
fi

if [ $CICD_PIPELINE == "true" ];
then
  # Enter Deployment type SHIP or TRAIN
  deployment_type=$DEPLOYMENT_TYPE
else
  # Enter Deployment type SHIP or TRAIN
  read -p "Enter Deployment type SHIP or TRAIN: " deployment_type
fi

# if deploment type is not SHIP or TRAIN, exit
if [ "$deployment_type" != "SHIP" ] && [ "$deployment_type" != "TRAIN" ]; then
    echo "Deployment type not specified"
    exit $?
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

if ! helm -v  &> /dev/null
then
    curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
fi


if [ $CICD_PIPELINE == "false" ];
then
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
fi


# Install System Packages
if [ ! -f /usr/bin/podman ]; then
  ./hack/partial-rpm-packages.sh
fi


# Run the configuration script to setup the bastion host with:
# - Python 3.9
# - Ansible
# - Ansible Navigator
# - Pip modules
result=$(whereis ansible-navigator)

# If the result only contains the name "ansible-navigator:" without a path, it means it's not installed
if [[ $result == "ansible-navigator:" ]]; then
    echo "ansible-navigator not found. Installing..."
    ./hack/partial-python39-setup.sh
else
    echo "ansible-navigator is already installed. Skipping installation."
fi


# Install OCP CLI Tools
if [ ! -f /usr/bin/oc ]; then
  ./hack/partial-setup-ocp-cli.sh
fi

# Check if already logged in to OpenShift
if oc whoami &> /dev/null; then
    echo "Already logged in to OpenShift."
else
    # Prompt user to enter the command for logging into the cluster
    echo "Example: oc login --token=sha256~xxxxxxxxx --server=https://api.example.com:6443"
    read -p "Enter the command to login to the cluster: " login_command

    # Run the next steps using the provided login command
    eval $login_command
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

cd $HOME

status=$(oc get ArgoCD openshift-gitops -n openshift-gitops -o jsonpath='{.status.phase}')

if [ "$status" == "Available" ]; then
    echo "ArgoCD is available."
else
    echo "ArgoCD is not available."
    git clone https://github.com/tosin2013/sno-quickstarts.git
    cd sno-quickstarts/gitops
    ./deploy.sh
fi


status=$(oc get pods hashicorp-vault-0 -n hashicorp-vault -o jsonpath='{.status.phase}')

# Check if the status is "Running"
if [ "$status" == "Running" ]; then
    echo "hashicorp-vault-0 is running."
    # Add any commands you want to run when the pod is running.
else
    echo "hashicorp-vault-0 is not running."
    $HOME/edge-anomaly-detection/hack/create-new-env-config.sh || exit $?
    cd $HOME/external-secrets-manager/
     ln -s /home/lab-user/.vault_password  .
    ansible-navigator run install-vault.yaml  --extra-vars "install_vault=true" \
    --vault-password-file $HOME/.vault_password -m stdout || exit $?
    GET_POD_NAME=$(oc get pods -n golang-external-secrets  | grep golang-external-secrets-webhook- | awk '{print $1}')
    wait-for-me "${GET_POD_NAME}" "golang-external-secrets"

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
fi


acm_status=$(oc get MultiClusterHub multiclusterhub -n open-cluster-management  -o jsonpath='{.status.phase}')

# Check if the status is "Running"
if [ "$acm_status" == "Running" ]; then
    echo "multiclusterhub is running."
    # Add any commands you want to run when the pod is running.
else
    cd $HOME/edge-anomaly-detection
    if [ "$deployment_type" == "SHIP" ]; then
        echo "Deploying SHIP"
        oc create -k clusters/overlays/rhdp-${OC_VERSION}-ships
        PODS_NAME=engine-room-monitoring-
   elif [ "$deployment_type" == "TRAIN" ]; then
        echo "Deploying TRAIN"
        yq -i '.kafka.broker.topic.topicname = "bullet"' charts/edge-datalake/values.yaml
        oc create -k clusters/overlays/rhdp-${OC_VERSION}-trains
        PODS_NAME=mock-railroad-
    else
        echo "Deployment type not specified"
        exit $?
    fi
fi

# Create a while loop to wait for acm_status to be Running
while [ "$acm_status" != "Running" ]; do
    sleep 25
    echo "Waiting for multiclusterhub to be Running..."
    acm_status=$(oc get MultiClusterHub multiclusterhub -n open-cluster-management  -o jsonpath='{.status.phase}')
done

cd $HOME/edge-anomaly-detection
sed -i 's/BUCKETNAME/'edge-anomaly-detection-$GUID'/g' charts/edge-datalake/values.yaml
sed -i 's/AWSREGION/us-east-2/g' charts/edge-datalake/values.yaml
GET_POD_NAME=$(oc get pods -n multicluster-engine  | grep cluster-image-set | awk '{print $1}')
wait-for-me "${GET_POD_NAME}" "multicluster-engine"
oc new-project edge-datalake
helm install charts/edge-datalake --generate-name  --namespace edge-datalake
helm template charts/external-secrets --generate-name | oc apply -f -
wait-for-me "prod-kafka-cluster-kafka-0" "edge-datalake"
wait-for-me "prod-kafka-cluster-kafka-1" "edge-datalake"
wait-for-me "prod-kafka-cluster-kafka-2" "edge-datalake"
GET_POD_NAME=$(oc get pods -n edge-anomaly-detection  | grep ${PODS_NAME} | awk '{print $1}')
oc delete pod $GET_POD_NAME -n edge-anomaly-detection
