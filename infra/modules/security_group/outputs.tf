output "eks_cluster_role_arn" {
  description = "Eks Cluster Iam role"
  value       = aws_security_group.eks_cluster.arn
}

output "eks_nodes_role_id" {
  description = "Eks Nodes Iam role"
  value       = aws_security_group.eks_worker_nodes.id
}