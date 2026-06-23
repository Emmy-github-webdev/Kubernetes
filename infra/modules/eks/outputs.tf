output "cluster_name" {
  value       = aws_eks_cluster.eks_cluster.name
  description = "EKS Cluster Name"
}

output "eks_cluster_endpoint" {
  value       = aws_eks_cluster.eks_cluster.endpoint
  description = "EKS Cluster API endpoint"
}

output "eks_cluster_certificate" {
  value       = aws_eks_cluster.eks_cluster.certificate_authority[0].data
  description = "Base64 encoded certificate data required to communicate with the cluster"
}

output "oidc_issuer_url" {
  value       = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
  description = "EKS Cluster OIDC Issuer URL"
}

output "eks_nodes_role_id" {
  value       = aws_iam_role.eks_nodegroup_role.id
  description = "IAM Role ID for EKS worker nodes"
}

output "eks_worker_nodes_sg_id" {
  value       = aws_security_group.eks_worker_nodes.id
  description = "Security group ID for EKS worker nodes"
}

output "eks_nodegroup_role_arn" {
  value       = aws_iam_role.eks_nodegroup_role.arn
  description = "ARN of the EKS node group IAM role"
}

output "eks_cluster_name" {
  value       = aws_eks_cluster.eks_cluster.name
  description = "EKS Cluster Name"
}

output "eks_cluster_arn" {
  value       = aws_eks_cluster.eks_cluster.arn
  description = "EKS Cluster ARN"
}

output "repository_url" {
  value = {
    for k, repo in aws_ecr_repository.eks_ecr_repository :
    k => repo.repository_url
  }
}

output "oidc_provider_arn" {
  value = aws_iam_openid_connect_provider.eks.arn
}