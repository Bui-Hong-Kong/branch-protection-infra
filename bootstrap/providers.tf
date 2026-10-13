provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project   = "branch-protection"
      Component = "terraform-state"
      ManagedBy = "terraform"
    }
  }
}
