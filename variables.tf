variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-1"
}

variable "environment" {
  description = "Environment label passed to resources (env-1 or env-2)"
  type        = string
}

variable "repository_name" {
  description = "ECR repository name for this environment"
  type        = string
}

variable "allowed_account_ids" {
  description = "Optional AWS account ID allow-list (empty = no restriction)"
  type        = list(string)
  default     = []
}

variable "keep_image_count" {
  description = "Tagged images to retain in ECR lifecycle policy"
  type        = number
  default     = 10
}
