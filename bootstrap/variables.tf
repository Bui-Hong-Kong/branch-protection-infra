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
