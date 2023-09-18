# Developer Documentation for Setup Bastion Contribution

## Overview

This script automates the setup and configuration of various tools and services, primarily for the deployment of the `edge-anomaly-detection` application. It ensures the necessary dependencies are installed, repositories are cloned, and configurations are applied.

## Prerequisites

- OpenShift CLI (`oc`)
- Bash shell
- Internet access

## Script Breakdown

### 1. Default Repository Name

The script sets a default repository name if not provided. This can be overridden by setting the `REPO_NAME` environment variable.

```bash
#REPO_NAME=${REPO_NAME:-tosin2013/external-secrets-manager}
```

### 2. `wait-for-me` Function

This function waits for a specific OpenShift pod to be in the "Ready" state.

```bash
function wait-for-me(){
    ...
}
```

### 3. Ansible Vault Password Configuration

The script checks if the `~/.vault_password` file exists and has content. If not, it downloads and runs the `ansible_vault_setup.sh` script to configure the Ansible Vault password.

### 4. AWS CLI Configuration

If the `configure-aws-cli.sh` script is not found in the home directory, the user is prompted for AWS credentials. The script then downloads and runs the AWS CLI configuration script and creates an S3 bucket.

### 5. Installation of Git, yq, and Helm

The script ensures that Git, `yq`, and Helm are installed on the system.

### 6. Repository Cloning and Updating

The script checks if the `edge-anomaly-detection` and `external-secrets-manager` repositories are already cloned. If they are, it updates them; otherwise, it clones them.

### 7. System Packages and Tools Installation

The script ensures that necessary system packages like `podman`, `ansible-navigator`, and OpenShift CLI tools are installed.

### 8. ArgoCD and Hashicorp Vault Status Checks

The script checks the status of ArgoCD and Hashicorp Vault. If they are not available or running, it performs the necessary setup and configuration.

### 9. MultiClusterHub Status Check

The script checks the status of the MultiClusterHub. If it's not running, it creates the necessary resources.

### 10. Edge Anomaly Detection Configuration

The script configures the `edge-anomaly-detection` application, updates its configuration files, and ensures the necessary pods are running.

## Contribution Guidelines

1. **Understand the Flow**: Before making changes, understand the flow and purpose of the script.
2. **Test Changes Locally**: Always test your changes locally before submitting a pull request.
3. **Comment Your Code**: Add comments to any new functions or logic you introduce for clarity.
4. **Maintain Idempotency**: Ensure that running the script multiple times won't produce different results or errors.
5. **Error Handling**: Add error handling for any new external commands or logic you introduce.
6. **Documentation**: Update this documentation if you introduce new features or significant changes to the script's flow.

