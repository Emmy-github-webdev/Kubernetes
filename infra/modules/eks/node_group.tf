resource "aws_launch_template" "eks_nodes" {
  name_prefix   = "eks-node-"
  instance_type = "t3.medium"

  network_interfaces {
    security_groups             = [aws_security_group.eks_worker_nodes.id]
    associate_public_ip_address = false
    delete_on_termination       = true
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.tags.project}-${var.tags.environment}-eks-node"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_eks_node_group" "eks_managed_node_group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "managed"
  node_role_arn   = aws_iam_role.eks_nodegroup_role.arn
  subnet_ids      = var.private_subnet_ids

  launch_template {
    id      = aws_launch_template.eks_nodes.id
    version = "$Latest"
  }

  scaling_config {
    desired_size = 2
    min_size     = 1
    max_size     = 5
  }
}

resource "aws_iam_role" "eks_nodegroup_role" {
  name = "${var.tags.project}-${var.tags.environment}-nodegroup-role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "eks-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_nodegroup_role.name
}

resource "aws_iam_role_policy_attachment" "eks-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_nodegroup_role.name
}

resource "aws_iam_role_policy_attachment" "eks-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_nodegroup_role.name
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
  description                  = "Allow worker nodes to communicate with the EKS control plane on HTTPS (port 443)"
  security_group_id            = aws_security_group.eks_worker_nodes.id
  referenced_security_group_id = aws_security_group.eks_cluster.id

  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443
}

# Allow control plane → worker node on kubelet port
resource "aws_vpc_security_group_ingress_rule" "eks_cluster_to_worker_kubelet" {
  description                  = "Allow EKS control plane to communicate with worker nodes on kubelet port"
  security_group_id            = aws_security_group.eks_worker_nodes.id
  referenced_security_group_id = aws_security_group.eks_cluster.id
  ip_protocol                  = "tcp"
  from_port                    = 10250
  to_port                      = 10250
}

# Node-to-Node Communication
resource "aws_vpc_security_group_ingress_rule" "eks_worker_self" {
  description                  = "Allow worker nodes to communicate with each other"
  security_group_id            = aws_security_group.eks_worker_nodes.id
  referenced_security_group_id = aws_security_group.eks_worker_nodes.id
  ip_protocol                  = "-1"
}

# worker nodes also need outbound internet/AWS access for image pull from ECR, AWS API, Update downloads
resource "aws_vpc_security_group_egress_rule" "eks_worker_all_out" {
  description       = "Allow all outbound traffic from EKS worker nodes"
  security_group_id = aws_security_group.eks_worker_nodes.id

  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"
}
