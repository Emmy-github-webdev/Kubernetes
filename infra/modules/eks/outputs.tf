output "cluster_name" {
  value       = aws_eks_cluster.eks_cluster.name
  description = "EKS Cluster Name"
}

output "oidc_issuer_url" {
  value       = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
  description = "EKS Cluster OIDC Issuer URL"
}

output "eks_nodes_role_id" {
  value       = aws_iam_role.eks_nodegroup_role.id
  description = "IAM Role ID for EKS worker nodes"
}