# App environment namespaces (workloads / Argo Applications live in the app repo).

resource "kubernetes_namespace" "sockshop" {
  for_each = toset(var.app_namespaces)

  metadata {
    name = each.key
    labels = {
      "app.kubernetes.io/part-of"    = "sockshop"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  depends_on = [module.eks]
}
