variable "tags" {
  description = "Global resources"
  type        = map(string)
  default     = {}
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the ALB Ingress Controller will be deployed"
  type        = string
}