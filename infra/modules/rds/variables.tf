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

variable "eks_oidc_provider_arn" {
  description = "EKS OIDC provider arn"
  type        = string
}

variable "eks_oidc_provider_url" {
  description = "EKS OIDC Provider URL"
  type        = string
}

variable "master_username" {
  description = "Master username for the RDS instance"
  type        = string
  default     = "masteradmin"
}