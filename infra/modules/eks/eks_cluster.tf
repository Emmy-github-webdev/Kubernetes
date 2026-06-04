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

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_eks_cluster" "eks_cluster" {
  name     = "${var.tags.project}-${var.tags.environment}-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = "1.34"

  vpc_config {
    endpoint_private_access = true
    endpoint_public_access  = true
    subnet_ids              = var.private_subnet_ids
    security_group_ids      = [aws_security_group.eks_cluster.id]
  }

  encryption_config {
    resources = ["secrets"]
    provider {
      key_arn = var.kms_key_arn
    }
  }
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

resource "aws_vpc_security_group_egress_rule" "eks_cluster_all_out" {
  description       = "Allow all outbound traffic from the EKS control plane"
  security_group_id = aws_security_group.eks_cluster.id

  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"
}