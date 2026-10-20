variable "region" {
  description = "AWS region for the shared platform (VPC + EKS)"
  type        = string
  default     = "ap-southeast-1"
}

variable "name_prefix" {
  description = "Name prefix for platform resources"
  type        = string
  default     = "branch-protection"
}

variable "allowed_account_ids" {
  description = "Optional AWS account ID allow-list for the provider"
  type        = list(string)
  default     = []
}

variable "vpc_cidr" {
  description = "CIDR for the platform VPC"
  type        = string
  default     = "10.40.0.0/16"
}

variable "azs" {
  description = "Pinned AZs for the platform VPC (avoid silent expansion when AWS adds zones)"
  type        = list(string)
  default     = ["ap-southeast-1a", "ap-southeast-1b"]
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.31"
}

variable "node_instance_types" {
  description = "Instance types for the managed node group"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_desired_size" {
  description = "Desired node count"
  type        = number
  default     = 2
}

variable "node_min_size" {
  description = "Minimum node count"
  type        = number
  default     = 1
}

variable "node_max_size" {
  description = "Maximum node count"
  type        = number
  default     = 3
}

variable "cluster_endpoint_public_access" {
  description = "Expose the EKS API publicly (lab convenience)"
  type        = bool
  default     = true
}
