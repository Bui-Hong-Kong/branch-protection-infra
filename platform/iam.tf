# Workload IAM for the shared EKS platform (IRSA).
# Install the controller later (Helm/Argo) using aws_load_balancer_controller_role_arn.

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
