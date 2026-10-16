variable "name" {
  description = "ECR repository name"
  type        = string
}

variable "environment" {
  description = "Environment label (e.g. env-1, env-2)"
  type        = string
}

variable "image_tag_mutability" {
  description = "IMMUTABLE blocks overwriting an existing tag with a different digest"
  type        = string
  default     = "IMMUTABLE"
}

variable "scan_on_push" {
  description = "Enable basic image scanning on push"
  type        = bool
  default     = true
}

variable "keep_image_count" {
  description = "How many tagged images to keep via lifecycle policy"
  type        = number
  default     = 10
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}
