# Cluster Security Group Used by the EKS control plane

resource "aws_security_group" "eks_cluster" {
  name        = "${var.tags.project}-${var.tags.environment}-cluster-sg"
  description = "EKS Cluster Security Group used by the EKS control plane"
  vpc_id      = var.eks_vpc_id

  tags = {
    Name = "${var.tags.project}-${var.tags.environment}-cluster-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "eks_cluster_https_from_nodes" {
  security_group_id            = aws_security_group.eks_cluster.id
  referenced_security_group_id = aws_security_group.eks_worker_nodes.id

  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443
}

resource "aws_vpc_security_group_egress_rule" "eks_cluster_all_out" {
  security_group_id = aws_security_group.eks_cluster.id

  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"
}

# Worker Node Security Group Used by the EC2 instances running Kubernetes workloads
resource "aws_security_group" "eks_worker_nodes" {
  name        = "${var.tags.project}-${var.tags.environment}-worker-sg"
  description = "EKS Worker Node Security Group Used by the EC2 instances running Kubernetes workloads"
  vpc_id      = var.eks_vpc_id

  tags = {
    Name = "${var.tags.project}-${var.tags.environment}-worker-sg"
  }
}

# Nodes → Cluster API Server
resource "aws_vpc_security_group_egress_rule" "eks_worker_to_cluster_https" {
  security_group_id            = aws_security_group.eks_worker_nodes.id
  referenced_security_group_id = aws_security_group.eks_cluster.id

  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443
}

# Node-to-Node Communication
resource "aws_vpc_security_group_ingress_rule" "eks_worker_self" {
  security_group_id            = aws_security_group.eks_worker_nodes.id
  referenced_security_group_id = aws_security_group.eks_worker_nodes.id

  ip_protocol = "-1"
}

# worker nodes also need outbound internet/AWS access for image pull from ECR, AWS API, Update downloads
resource "aws_vpc_security_group_egress_rule" "eks_worker_all_out" {
  security_group_id = aws_security_group.eks_worker_nodes.id

  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"
}