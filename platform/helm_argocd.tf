# Argo CD control plane only — Application / app manifests stay in the app (GitOps) repo.

resource "helm_release" "argo_cd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = var.argo_cd_chart_version
  namespace        = "argocd"
  create_namespace = true

  atomic          = true
  cleanup_on_fail = true
  wait            = true
  timeout         = 900

  # Lab defaults: single replica, ClusterIP (kubectl port-forward).
  set {
    name  = "server.service.type"
    value = "ClusterIP"
  }

  set {
    name  = "configs.params.server\\.insecure"
    value = "true"
  }

  depends_on = [
    module.eks,
    helm_release.aws_load_balancer_controller,
  ]
}