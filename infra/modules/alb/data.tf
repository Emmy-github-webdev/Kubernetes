data "kubernetes_ingress_v1" "api" {
  metadata {
    name      = "ingress-${var.tags.environment}"
    namespace = var.tags.environment
  }
}

data "aws_lb" "api" {
  name = split(
    ".",
    data.kubernetes_ingress_v1.api.status[0].load_balancer[0].ingress[0].hostname
  )[0]
}