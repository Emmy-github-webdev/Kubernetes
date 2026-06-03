variable "tags" {
  description = "Global resources"
  type        = map(string)
  default     = {}
}

variable "eks_cluster_role_arn" {
  description = "ARN of the IAM role to be used by the EKS cluster"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for the EKS cluster"
  type        = list(string)
}