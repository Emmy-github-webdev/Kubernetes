variable "tags" {
  description = "Global resources"
  type        = map(string)
  default     = {}
}

variable "vpc_flow_logs_arn" {
  description = "IAM Role ARN for VPC flow logs"
  type        = string
}

output "eks_cluster_role_arn" {
  description = "ARN of the IAM role for EKS cluster"
  value       = aws_iam_role.eks_cluster_role.arn
}