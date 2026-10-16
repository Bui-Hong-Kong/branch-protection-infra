output "repository_names" {
  description = "ECR repository names for this environment"
  value       = { for k, m in module.ecr : k => m.repository_name }
}

output "repository_urls" {
  description = "ECR repository URLs for this environment"
  value       = { for k, m in module.ecr : k => m.repository_url }
}

output "repository_arns" {
  description = "ECR repository ARNs for this environment"
  value       = { for k, m in module.ecr : k => m.repository_arn }
}

output "registry_id" {
  description = "Registry ID (AWS account ID)"
  value       = values(module.ecr)[0].registry_id
}
