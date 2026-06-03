output "cluster_name" {
  value       = aws_eks_cluster.eks_cluster.name
  description = "EKS Cluster Name"
}