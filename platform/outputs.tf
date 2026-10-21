output "vpc_id" {
  description = "Platform VPC ID"
  value       = module.vpc.vpc_id
}

output "private_subnet_ids" {
  description = "Private subnet IDs (EKS nodes)"
  value       = module.vpc.private_subnets
}

output "public_subnet_ids" {
  description = "Public subnet IDs (ALB)"
  value       = module.vpc.public_subnets
}

output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS API endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  description = "EKS cluster CA (base64)"
  value       = module.eks.cluster_certificate_authority_data
  sensitive   = true
}

output "oidc_provider_arn" {
  description = "EKS OIDC provider ARN (IRSA)"
  value       = module.eks.oidc_provider_arn
}

output "configure_kubectl" {
  description = "Command to update kubeconfig"
  value       = "aws eks update-kubeconfig --region ${var.region} --name ${module.eks.cluster_name}"
}

output "aws_load_balancer_controller_role_arn" {
  description = "IRSA role ARN for aws-load-balancer-controller (kube-system)"
  value       = module.aws_load_balancer_controller_irsa.iam_role_arn
}

output "app_namespaces" {
  description = "Sock Shop namespaces created on the cluster"
  value       = sort(keys(kubernetes_namespace.sockshop))
}

output "argocd_namespace" {
  description = "Namespace where Argo CD is installed"
  value       = helm_release.argo_cd.namespace
}

output "argocd_admin_password_hint" {
  description = "How to read the initial Argo CD admin password"
  value       = "kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"
}

output "argocd_port_forward_hint" {
  description = "Local UI access (ClusterIP service)"
  value       = "kubectl -n argocd port-forward svc/argocd-server 8080:443"
}
