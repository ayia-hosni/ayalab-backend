#!/usr/bin/env bash
# One-time setup for the Azure deploy GitHub Actions workflow. Run this once
# (from a machine logged into `az` with rights to create resources + service
# principals), then copy the printed values into GitHub repo secrets. Safe to
# re-run: storage account / RG creation is idempotent, but re-running the
# service-principal step issues a NEW client secret each time.
set -euo pipefail

STATE_RG="ayalab-tfstate-rg"
STATE_LOCATION="eastus"
STATE_STORAGE_ACCOUNT="ayalabtfstate$RANDOM"   # must be globally unique, 3-24 lowercase alphanumeric
STATE_CONTAINER="tfstate"

echo "== Creating resource group for Terraform state =="
az group create --name "$STATE_RG" --location "$STATE_LOCATION" >/dev/null

echo "== Creating storage account for Terraform state: $STATE_STORAGE_ACCOUNT =="
az storage account create \
  --name "$STATE_STORAGE_ACCOUNT" \
  --resource-group "$STATE_RG" \
  --sku Standard_LRS \
  --encryption-services blob >/dev/null

echo "== Creating blob container: $STATE_CONTAINER =="
ACCOUNT_KEY=$(az storage account keys list --resource-group "$STATE_RG" --account-name "$STATE_STORAGE_ACCOUNT" --query '[0].value' -o tsv)
az storage container create \
  --name "$STATE_CONTAINER" \
  --account-name "$STATE_STORAGE_ACCOUNT" \
  --account-key "$ACCOUNT_KEY" >/dev/null

echo "== Creating a service principal for GitHub Actions (Contributor on this subscription) =="
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
SP_JSON=$(az ad sp create-for-rbac --name "ayalab-github-actions" --role Contributor --scopes "/subscriptions/$SUBSCRIPTION_ID" -o json)

CLIENT_ID=$(echo "$SP_JSON" | python3 -c 'import json,sys;print(json.load(sys.stdin)["appId"])')
CLIENT_SECRET=$(echo "$SP_JSON" | python3 -c 'import json,sys;print(json.load(sys.stdin)["password"])')
TENANT_ID=$(echo "$SP_JSON" | python3 -c 'import json,sys;print(json.load(sys.stdin)["tenant"])')

echo ""
echo "=================================================================="
echo "Add these as GitHub repo secrets (Settings > Secrets and variables"
echo "> Actions) on ayia-hosni/ayalab-backend:"
echo "=================================================================="
echo "AZURE_CLIENT_ID          = $CLIENT_ID"
echo "AZURE_CLIENT_SECRET      = $CLIENT_SECRET"
echo "AZURE_SUBSCRIPTION_ID    = $SUBSCRIPTION_ID"
echo "AZURE_TENANT_ID          = $TENANT_ID"
echo "TF_STATE_RESOURCE_GROUP  = $STATE_RG"
echo "TF_STATE_STORAGE_ACCOUNT = $STATE_STORAGE_ACCOUNT"
echo "TF_STATE_CONTAINER       = $STATE_CONTAINER"
echo ""
echo "Also set (values only you should choose, not printed here):"
echo "TF_DB_PASSWORD       = <a strong Postgres admin password>"
echo "TF_SSH_PUBLIC_KEY    = <contents of a dedicated deploy keypair's .pub file>"
echo "TF_SSH_PRIVATE_KEY   = <contents of that keypair's private key file>"
echo "TF_FRONTEND_ORIGIN   = <your frontend URL, e.g. https://ayalab.co>"
echo "=================================================================="
echo "The CLIENT_SECRET above is shown only once — store it now."
