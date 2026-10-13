# Partial backend — pass bucket/table/region via:
#   terraform init -backend-config=...
# See bootstrap outputs and repo README.
terraform {
  backend "s3" {
    key      = "branch-protection/env-2/terraform.tfstate"
    encrypt  = true
  }
}
