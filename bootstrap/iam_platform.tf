# Dedicated GHA role for platform/ (VPC + EKS + IRSA).
# ECR env stacks keep using aws_iam_role.github_actions (iam.tf).

data "aws_iam_policy_document" "github_actions_platform_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = [local.github_subject]
    }
  }
}

data "aws_iam_policy_document" "github_actions_platform" {
  statement {
    sid       = "StateList"
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.state.arn]
  }

  statement {
    sid    = "StateObjectsPlatform"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]
    resources = ["${aws_s3_bucket.state.arn}/${var.name_prefix}/platform/*"]
  }

  statement {
    sid    = "StateLock"
    effect = "Allow"
    actions = [
      "dynamodb:DescribeTable",
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem",
    ]
    resources = [aws_dynamodb_table.lock.arn]
  }

  # Lab-oriented breadth; tighten later if needed.
  statement {
    sid    = "PlatformNetworking"
    effect = "Allow"
    actions = [
      "ec2:*",
      "elasticloadbalancing:*",
    ]
    resources = ["*"]
  }

  statement {
    sid       = "PlatformEks"
    effect    = "Allow"
    actions   = ["eks:*"]
    resources = ["*"]
  }

  statement {
    sid    = "PlatformIam"
    effect = "Allow"
    actions = [
      "iam:CreateRole",
      "iam:DeleteRole",
      "iam:GetRole",
      "iam:TagRole",
      "iam:UntagRole",
      "iam:ListRolePolicies",
      "iam:ListAttachedRolePolicies",
      "iam:ListInstanceProfilesForRole",
      "iam:AttachRolePolicy",
      "iam:DetachRolePolicy",
      "iam:PutRolePolicy",
      "iam:GetRolePolicy",
      "iam:DeleteRolePolicy",
      "iam:CreateOpenIDConnectProvider",
      "iam:DeleteOpenIDConnectProvider",
      "iam:GetOpenIDConnectProvider",
      "iam:TagOpenIDConnectProvider",
      "iam:UntagOpenIDConnectProvider",
      "iam:UpdateAssumeRolePolicy",
      "iam:PassRole",
      "iam:CreateServiceLinkedRole",
      "iam:CreateInstanceProfile",
      "iam:DeleteInstanceProfile",
      "iam:GetInstanceProfile",
      "iam:AddRoleToInstanceProfile",
      "iam:RemoveRoleFromInstanceProfile",
      "iam:TagInstanceProfile",
    ]
    resources = ["*"]
  }

  statement {
    sid       = "PlatformAutoscaling"
    effect    = "Allow"
    actions   = ["autoscaling:*"]
    resources = ["*"]
  }

  statement {
    sid    = "PlatformLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:DeleteLogGroup",
      "logs:DescribeLogGroups",
      "logs:ListTagsForResource",
      "logs:TagResource",
      "logs:UntagResource",
      "logs:PutRetentionPolicy",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "PlatformKms"
    effect = "Allow"
    actions = [
      "kms:DescribeKey",
      "kms:CreateGrant",
      "kms:ListGrants",
      "kms:RevokeGrant",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role" "github_actions_platform" {
  name               = "${var.name_prefix}-gha-platform"
  assume_role_policy = data.aws_iam_policy_document.github_actions_platform_trust.json

  tags = {
    Name      = "${var.name_prefix}-gha-platform"
    Component = "github-actions-platform"
  }
}

resource "aws_iam_role_policy" "github_actions_platform" {
  name   = "${var.name_prefix}-gha-platform"
  role   = aws_iam_role.github_actions_platform.id
  policy = data.aws_iam_policy_document.github_actions_platform.json
}
