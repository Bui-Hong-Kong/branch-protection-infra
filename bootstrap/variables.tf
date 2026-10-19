variable "region" {
  description = "AWS region for the state bucket and lock table"
  type        = string
  default     = "ap-southeast-1"
}

variable "name_prefix" {
  description = "Prefix for state bucket and lock table names"
  type        = string
  default     = "branch-protection"
}

variable "github_repository" {
  description = "GitHub repository allowed to assume the Terraform role (human-readable org/name)"
  type        = string
  default     = "Bui-Hong-Kong/branch-protection-infra"
}

# Immutable OIDC sub prefix from GitHub: owner@owner_id/repo@repo_id
variable "github_repository_oidc" {
  description = "Immutable GitHub OIDC repo segment for the Terraform role trust"
  type        = string
  default     = "Bui-Hong-Kong@301616666/branch-protection-infra@1416442090"
}

variable "github_ref" {
  description = "Git ref allowed to assume the Terraform role"
  type        = string
  default     = "refs/heads/main"
}

variable "ecr_services" {
  description = "Sock Shop service IDs used to build ECR repository names"
  type        = list(string)
  default = [
    "carts",
    "catalogue",
    "orders",
    "payment",
    "shipping",
    "user",
    "frontend",
    "test-terraform",
  ]
}

variable "ecr_repository_name_prefix" {
  description = "Prefix for ECR repository names (sockshop-<service>-env-N)"
  type        = string
  default     = "sockshop"
}

variable "image_repository" {
  description = "GitHub repository allowed to push and copy images (human-readable org/name)"
  type        = string
  default     = "Bui-Hong-Kong/branch-protection"
}

# Immutable OIDC sub prefix from GitHub: owner@owner_id/repo@repo_id
variable "image_repository_oidc" {
  description = "Immutable GitHub OIDC repo segment for push/copy role trust"
  type        = string
  default     = "Bui-Hong-Kong@301616666/branch-protection@1409996567"
}

variable "image_push_ref" {
  description = "Git ref allowed to push images to env-1"
  type        = string
  default     = "refs/heads/main"
}

variable "image_copy_environment" {
  description = "GitHub Environment allowed to copy images from env-1 to env-2"
  type        = string
  default     = "env-2"
}
