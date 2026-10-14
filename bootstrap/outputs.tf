output "state_bucket" {
  description = "S3 bucket name for Terraform remote state"
  value       = aws_s3_bucket.state.bucket
}

output "lock_table" {
  description = "DynamoDB table name for Terraform state locking"
  value       = aws_dynamodb_table.lock.name
}

output "region" {
  description = "AWS region of the state backend"
  value       = var.region
}

output "account_id" {
  description = "AWS account ID that owns the backend"
  value       = data.aws_caller_identity.current.account_id
}

output "github_actions_role_arn" {
  description = "IAM role ARN for GitHub Actions. Set this as the GitHub variable AWS_ROLE_ARN."
  value       = aws_iam_role.github_actions.arn
}

output "backend_config_example" {
  description = "Example terraform init -backend-config flags for environment stacks"
  value       = <<-EOT
    -backend-config="bucket=${aws_s3_bucket.state.bucket}"
    -backend-config="region=${var.region}"
    -backend-config="dynamodb_table=${aws_dynamodb_table.lock.name}"
    -backend-config="encrypt=true"
  EOT
}
