# Workload IAM for the shared EKS platform (IRSA).
# Helm release aws-load-balancer-controller annotates SA with this role ARN.

module "aws_load_balancer_controller_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.52"

  role_name = "${var.name_prefix}-aws-lb-controller"

  attach_load_balancer_controller_policy = true

  oidc_providers = {
    this = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }

  tags = {
    Name      = "${var.name_prefix}-aws-lb-controller"
    Component = "alb-controller"
  }
}

# Argo CD Image Updater — list/pull metadata from private ECR (write-back Git uses a PAT secret, not TF).
module "argocd_image_updater_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.52"

  role_name = "${var.name_prefix}-argocd-image-updater"

  role_policy_arns = {
    ecr = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  }

  oidc_providers = {
    this = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["argocd:argocd-image-updater"]
    }
  }

  tags = {
    Name      = "${var.name_prefix}-argocd-image-updater"
    Component = "argocd-image-updater"
  }
}
