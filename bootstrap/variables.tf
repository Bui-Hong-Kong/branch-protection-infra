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
  description = "GitHub repository allowed to assume the Terraform role (org/name)"
  type        = string
  default     = "Bui-Hong-Kong/branch-protection-infra"
}

variable "github_ref" {
  description = "Git ref allowed to assume the Terraform role"
  type        = string
  default     = "refs/heads/main"
}

variable "ecr_repository_names" {
  description = "ECR repository names the GitHub Actions role may manage"
  type        = list(string)
  default     = ["branch-protection-env-1", "branch-protection-env-2"]
}
