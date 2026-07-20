data "kubernetes_ingress_v1" "api" {
  metadata {
    name      = "ingress-${var.tags.environment}"
    namespace = var.tags.environment
  }
}

data "aws_elb_hosted_zone_id" "main" {}