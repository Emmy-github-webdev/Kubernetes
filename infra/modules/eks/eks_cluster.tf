resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.tags.project}-${var.tags.environment}-eks-cluster-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_eks_cluster" "eks_cluster" {
  name     = "${var.tags.project}-${var.tags.environment}-eks-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = "1.33"

  vpc_config {
    endpoint_private_access = true
    endpoint_public_access  = true
    subnet_ids              = var.private_subnet_ids
  }

  encryption_config {
    resources = ["secrets"]
    provider {
      key_arn = var.kms_key_arn
    }
  }
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  tags = {
    Name = "${var.tags.project}-${var.tags.environment}-eks-cluster"
  }
}