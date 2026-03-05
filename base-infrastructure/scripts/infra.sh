#!/bin/bash

set -x
set -e

ACTION=$1   # plan or apply

az login --service-principal \
    -u "$AZURE_CLIENT_ID" \
    -p "$AZURE_CLIENT_SECRET" \
    --tenant "$AZURE_TENANT_ID"

cd base-infrastructure/terraform

terraform init

if [ "$ACTION" = "plan" ]; then
    terraform plan
elif [ "$ACTION" = "apply" ]; then
    # TODO: Remove auto-approve and add a confirmation step with plan
    terraform apply -auto-approve
else
    echo "Invalid action: $ACTION"
    exit 1
fi
