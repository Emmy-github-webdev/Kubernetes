resource "aws_eks_addon" "vpc_cni" {
  cluster_name = var.cluster_name
  addon_name   = "vpc-cni"
}

resource "aws_eks_addon" "coredns" {
  cluster_name = var.cluster_name
  addon_name   = "coredns"

  configuration_values = jsonencode({
    replicaCount = 2

    resources = {
      requests = {
        cpu    = "100m"
        memory = "70Mi"
      }

      limits = {
        cpu    = "250m"
        memory = "170Mi"
      }
    }
  })
}