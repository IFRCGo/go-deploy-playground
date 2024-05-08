#!/bin/bash

set -x
set -e

az login --service-principal -u $AZURE_CLIENT_ID -p $AZURE_CLIENT_SECRET --tenant $AZURE_TENANT_ID

cd base-infrastructure/terraform

terraform init
terraform plan
