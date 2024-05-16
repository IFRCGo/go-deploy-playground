#!/bin/bash

set -x
set -e

echo "Printing the credentials for debugging"
echo $AZURE_CLIENT_ID
echo $AZURE_CLIENT_SECRET
echo $AZURE_TENANT_ID

az login --service-principal -u $AZURE_CLIENT_ID -p $AZURE_CLIENT_SECRET --tenant $AZURE_TENANT_ID

cd base-infrastructure/terraform

terraform init
terraform plan
