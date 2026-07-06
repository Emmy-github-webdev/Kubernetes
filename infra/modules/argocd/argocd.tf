resource "helm_release" "argocd" {
  name             = "${var.tags.project}-${var.tags.environment}-argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true

  values = [
    file("${path.module}/values.yaml")
  ]
}
