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

variable "app_namespaces" {
  description = "Sock Shop environment namespaces on the shared EKS cluster"
  type        = list(string)
  default     = ["sockshop-dev", "sockshop-uat", "sockshop-prod"]
}

variable "aws_load_balancer_controller_chart_version" {
  description = "Helm chart version for aws-load-balancer-controller"
  type        = string
  default     = "1.11.0"
}

variable "argo_cd_chart_version" {
  description = "Helm chart version for argo-cd (argo-helm)"
  type        = string
  default     = "7.8.13"
}

variable "argo_image_updater_chart_version" {
  description = "Helm chart version for argocd-image-updater (argo-helm)"
  type        = string
  default     = "0.12.3"
}

variable "catalogue_db_instance_class" {
  description = "RDS instance class for Sock Shop catalogue (MySQL)"
  type        = string
  default     = "db.t4g.micro"
}

variable "catalogue_db_engine_version" {
  description = "MySQL engine version for catalogue RDS"
  type        = string
  default     = "8.0"
}

variable "catalogue_db_allocated_storage" {
  description = "Allocated storage (GiB) for catalogue RDS"
  type        = number
  default     = 20
}

variable "catalogue_db_max_allocated_storage" {
  description = "Autoscaling storage ceiling (GiB); 0 disables"
  type        = number
  default     = 50
}

variable "catalogue_db_name" {
  description = "Initial database name (Sock Shop socksdb)"
  type        = string
  default     = "socksdb"
}

variable "catalogue_db_username" {
  description = "Master username for catalogue RDS"
  type        = string
  default     = "catalogue_user"
}

variable "catalogue_db_backup_retention_period" {
  description = "Automated backup retention days (0 disables; lab may use 1)"
  type        = number
  default     = 1
}
