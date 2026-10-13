variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-1"
}

variable "repository_name" {
  description = "ECR repository name for this environment"
  type        = string
  default     = "branch-protection-env-2"
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
