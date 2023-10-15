# Deploy Via Github Actions

## Prerequisites
Review the following before deploying to RHEL 8:
[How to use GitHub Action to Run SSH Commands](https://medium.com/p/609df2a88ac3)
```
$ ./copy-keys.sh lab-user@hypervisor.example.com  username@example.com
```

AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
AWS_REGION
SSH_PASSWORD
DEPLOYMENT_TYPE
OPENSHIFT_URL
OPENSHIFT_TOKEN

To create GitHub Action secrets, you need to go to your GitHub repository, navigate to the "Settings" tab, and then select "Secrets" from the sidebar. Here are step-by-step instructions on how to create each of the GitHub Action secrets you mentioned:

1. **AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_REGION:**

   a. Navigate to your GitHub repository.
   
   b. Click on the "Settings" tab.
   
   c. In the left sidebar, click on "Secrets."

   d. Click the "New repository secret" button.

   e. Enter `AWS_ACCESS_KEY_ID` in the "Name" field and your AWS access key in the "Value" field.

   f. Click the "Add secret" button.

   g. Repeat the same process for `AWS_SECRET_ACCESS_KEY` and `AWS_REGION`.

2. **SSH_PASSWORD:**

   a. Navigate to your GitHub repository.
   
   b. Click on the "Settings" tab.
   
   c. In the left sidebar, click on "Secrets."

   d. Click the "New repository secret" button.

   e. Enter `SSH_PASSWORD` in the "Name" field and your SSH password in the "Value" field.

   f. Click the "Add secret" button.

3. **OPENSHIFT_URL and OPENSHIFT_TOKEN:**

   a. Navigate to your GitHub repository.
   
   b. Click on the "Settings" tab.
   
   c. In the left sidebar, click on "Secrets."

   d. Click the "New repository secret" button.

   e. Enter `OPENSHIFT_URL` in the "Name" field and your OpenShift URL in the "Value" field. Example: https://api.ocp4.example.com:6443

   f. Click the "Add secret" button.

   g. Repeat the same process for `OPENSHIFT_TOKEN`.

## Deploying to OpenShift cluster