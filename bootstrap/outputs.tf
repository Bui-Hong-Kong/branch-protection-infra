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
  description = "IAM role ARN for Terraform in branch-protection-infra. Set this as the GitHub variable AWS_ROLE_ARN on that repo."
  value       = aws_iam_role.github_actions.arn
}

output "ecr_push_role_arn" {
  description = "IAM role ARN for pushing images to env-1. Set this as a GitHub variable on branch-protection."
  value       = aws_iam_role.ecr_push.arn
}

output "ecr_copy_role_arn" {
  description = "IAM role ARN for copying images from env-1 to env-2. Set this as a GitHub variable on branch-protection."
  value       = aws_iam_role.ecr_copy.arn
}

output "backend_config_example" {
  description = "Example terraform init -backend-config flags for environment stacks"
  value       = <<-EOT
    -backend-config="bucket=${aws_s3_bucket.state.bucket}"
    -backend-config="region=${var.region}"
    -backend-config="use_lockfile=true"
    -backend-config="encrypt=true"
  EOT
}
