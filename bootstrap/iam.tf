locals {
  github_subject     = "repo:${var.github_repository}:ref:${var.github_ref}"
  image_push_subject = "repo:${var.image_repository}:ref:${var.image_push_ref}"
  image_copy_subject = "repo:${var.image_repository}:environment:${var.image_copy_environment}"
  ecr_repository_arns = [
    for name in var.ecr_repository_names :
    "arn:aws:ecr:${var.region}:${local.account_id}:repository/${name}"
  ]
  ecr_push_repository_arn  = "arn:aws:ecr:${var.region}:${local.account_id}:repository/${var.ecr_push_repository}"
  ecr_copy_source_arn      = "arn:aws:ecr:${var.region}:${local.account_id}:repository/${var.ecr_copy_source_repository}"
  ecr_copy_destination_arn = "arn:aws:ecr:${var.region}:${local.account_id}:repository/${var.ecr_copy_destination_repository}"
}

resource "aws_iam_openid_connect_provider" "github" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
  # GitHub's published thumbprint. IAM still requires the field; AWS validates GitHub via its trusted CA store.
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]

  tags = {
    Name      = "${var.name_prefix}-github-oidc"
    Component = "github-actions"
  }
}

data "aws_iam_policy_document" "github_actions_trust" {
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

data "aws_iam_policy_document" "github_actions" {
  statement {
    sid       = "StateList"
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.state.arn]
  }

  statement {
    sid    = "StateObjects"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]
    resources = ["${aws_s3_bucket.state.arn}/${var.name_prefix}/*"]
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

  statement {
    sid    = "EcrRepositories"
    effect = "Allow"
    actions = [
      "ecr:CreateRepository",
      "ecr:DeleteRepository",
      "ecr:DescribeRepositories",
      "ecr:TagResource",
      "ecr:ListTagsForResource",
      "ecr:PutLifecyclePolicy",
      "ecr:GetLifecyclePolicy",
      "ecr:DeleteLifecyclePolicy",
      "ecr:PutImageScanningConfiguration",
      "ecr:PutImageTagMutability",
    ]
    resources = local.ecr_repository_arns
  }
}

resource "aws_iam_role" "github_actions" {
  name               = "${var.name_prefix}-gha-terraform"
  assume_role_policy = data.aws_iam_policy_document.github_actions_trust.json

  tags = {
    Name      = "${var.name_prefix}-gha-terraform"
    Component = "github-actions"
  }
}

resource "aws_iam_role_policy" "github_actions" {
  name   = "${var.name_prefix}-gha-terraform"
  role   = aws_iam_role.github_actions.id
  policy = data.aws_iam_policy_document.github_actions.json
}

data "aws_iam_policy_document" "ecr_push_trust" {
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
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = [local.image_push_subject]
    }
  }
}

data "aws_iam_policy_document" "ecr_push" {
  statement {
    sid       = "EcrAuth"
    effect    = "Allow"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  statement {
    sid    = "PushEnv1"
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:PutImage",
    ]
    resources = [local.ecr_push_repository_arn]
  }
}

resource "aws_iam_role" "ecr_push" {
  name               = "${var.name_prefix}-gha-push"
  assume_role_policy = data.aws_iam_policy_document.ecr_push_trust.json

  tags = {
    Name      = "${var.name_prefix}-gha-push"
    Component = "github-actions"
  }
}

resource "aws_iam_role_policy" "ecr_push" {
  name   = "${var.name_prefix}-gha-push"
  role   = aws_iam_role.ecr_push.id
  policy = data.aws_iam_policy_document.ecr_push.json
}

data "aws_iam_policy_document" "ecr_copy_trust" {
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
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = [local.image_copy_subject]
    }
  }
}

data "aws_iam_policy_document" "ecr_copy" {
  statement {
    sid       = "EcrAuth"
    effect    = "Allow"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  statement {
    sid    = "ReadEnv1"
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:GetDownloadUrlForLayer",
    ]
    resources = [local.ecr_copy_source_arn]
  }

  statement {
    sid    = "WriteEnv2"
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:PutImage",
    ]
    resources = [local.ecr_copy_destination_arn]
  }
}

resource "aws_iam_role" "ecr_copy" {
  name               = "${var.name_prefix}-gha-copy"
  assume_role_policy = data.aws_iam_policy_document.ecr_copy_trust.json

  tags = {
    Name      = "${var.name_prefix}-gha-copy"
    Component = "github-actions"
  }
}

resource "aws_iam_role_policy" "ecr_copy" {
  name   = "${var.name_prefix}-gha-copy"
  role   = aws_iam_role.ecr_copy.id
  policy = data.aws_iam_policy_document.ecr_copy.json
}
