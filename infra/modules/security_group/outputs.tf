output "eks_cluster_sg_id" {
  description = "EKS Cluster Security Group ID"
  value       = aws_security_group.eks_cluster.id
}

output "eks_worker_nodes_sg_id" {
  description = "EKS Worker Nodes Security Group ID"
  value       = aws_security_group.eks_worker_nodes.id
}

output "eks_nodes_role_id" {
  description = "Eks Nodes Iam role"
  value       = aws_security_group.eks_worker_nodes.id
}