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

resource "kubernetes_manifest" "argocd_root_app" {

  depends_on = [
    helm_release.argocd
  ]

  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"

    metadata = {
      name      = "${var.tags.environment}-platform-root"
      namespace = "argocd"
    }

    spec = {
      project = "default"

      source = {
        repoURL        = "https://github.com/Emmy-github-webdev/Kubernetes-argocd.git"
        targetRevision = "main"
        path           = "argocd/${var.tags.environment}"
      }

      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "argocd"
      }

      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
      }
    }
  }
}