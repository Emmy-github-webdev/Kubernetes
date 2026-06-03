resource "aws_eks_node_group" "eks_managed_node_group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "managed"
  node_role_arn   = aws_iam_role.eks_nodegroup_role.arn

  subnet_ids = [
    for subnet in aws_subnet.private : var.private_subnet_ids[subnet.id]
  ]

  scaling_config {
    desired_size = 2
    min_size     = 1
    max_size     = 5
  }
}

resource "aws_iam_role" "eks_nodegroup_role" {
  name = "${var.tags.project}-${var.tags.environment}-eks-nodegroup-role"

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