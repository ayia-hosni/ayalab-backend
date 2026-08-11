# Remote state so CI runs share the same state as local runs instead of each
# starting blind. Values are supplied at `terraform init` time via
# -backend-config (see .github/workflows/deploy-azure.yml and
# terraform-azure/README-CI.md) so nothing environment-specific lives here.
terraform {
  backend "azurerm" {}
}
