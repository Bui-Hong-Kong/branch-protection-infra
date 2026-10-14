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
  description = "ECR repository names the Terraform role may manage"
  type        = list(string)
  default     = ["branch-protection-env-1", "branch-protection-env-2"]
}

variable "image_repository" {
  description = "GitHub repository allowed to push and copy images (org/name)"
  type        = string
  default     = "Bui-Hong-Kong/branch-protection"
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

variable "ecr_push_repository" {
  description = "ECR repository the push role may write"
  type        = string
  default     = "branch-protection-env-1"
}

variable "ecr_copy_source_repository" {
  description = "ECR repository the copy role may read"
  type        = string
  default     = "branch-protection-env-1"
}

variable "ecr_copy_destination_repository" {
  description = "ECR repository the copy role may write"
  type        = string
  default     = "branch-protection-env-2"
}
