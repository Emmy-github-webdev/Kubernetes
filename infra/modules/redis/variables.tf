variable "tags" {
  description = "Global resources"
  type        = map(string)
  default     = {}
}

variable "private_subnet_ids" {
  description = "The private subnet ID"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "eks_node_security_group_id" {
  description = "EKS node security group ID"
  type        = string
}