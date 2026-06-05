data "aws_caller_identity" "current" {}

resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.tags.project}-${var.tags.environment}-cluster-role"
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

resource "aws_iam_role" "eks_admin" {
  name = "${var.tags.project}-${var.tags.environment}-eks-admin"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_eks_access_entry" "admin" {
  cluster_name  = aws_eks_cluster.eks_cluster.name
  principal_arn = aws_iam_role.eks_admin.arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "admin" {
  cluster_name  = aws_eks_cluster.eks_cluster.name
  principal_arn = aws_iam_role.eks_admin.arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }
}

resource "aws_eks_cluster" "eks_cluster" {
  name     = "${var.tags.project}-${var.tags.environment}-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = "1.33"

  access_config {
    authentication_mode = "API"
  }

  vpc_config {
    endpoint_private_access = true
    endpoint_public_access  = true
    subnet_ids              = var.private_subnet_ids
    security_group_ids      = [aws_security_group.eks_cluster.id]
  }

  # encryption_config {
  #   resources = ["secrets"]
  #   provider {
  #     key_arn = var.kms_key_arn
  #   }
  # }
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  tags = {
    Name = "${var.tags.project}-${var.tags.environment}-cluster"
  }
}


resource "aws_security_group" "eks_cluster" {
  name        = "${var.tags.project}-${var.tags.environment}-cluster-sg"
  description = "EKS Cluster Security Group used by the EKS control plane"
  vpc_id      = var.eks_vpc_id

  tags = {
    Name = "${var.tags.project}-${var.tags.environment}-cluster-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "eks_cluster_https_from_nodes" {
  description                  = "Allow worker nodes to communicate with the EKS control plane on HTTPS (port 443)"
  security_group_id            = aws_security_group.eks_cluster.id
  referenced_security_group_id = aws_security_group.eks_worker_nodes.id

  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443
}

# GitHub OIDC access
locals {
  github_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/github-Kubernetes-${var.tags.environment}-role"
}

resource "aws_eks_access_entry" "github" {
  cluster_name  = aws_eks_cluster.eks_cluster.name
  principal_arn = local.github_role_arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "github" {
  cluster_name  = aws_eks_cluster.eks_cluster.name
  principal_arn = local.github_role_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }
}