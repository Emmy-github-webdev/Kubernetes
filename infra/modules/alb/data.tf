data "kubernetes_ingress_v1" "api" {
  metadata {
    name      = "ingress-${var.tags.environment}"
    namespace = var.tags.environment
  }
}