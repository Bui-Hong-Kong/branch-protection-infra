provider "aws" {
  region              = var.region
  allowed_account_ids = length(var.allowed_account_ids) > 0 ? var.allowed_account_ids : null

  default_tags {
    tags = {
      Project     = "branch-protection"
      Environment = "env-1"
      ManagedBy   = "terraform"
    }
  }
}
