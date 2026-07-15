variable "tags" {
  description = "Global resources"
  type        = map(string)
  default     = {}
}

variable "services" {
  description = "Microservices requiring PostgreSQL databases"

  type = map(object({
    db = string
  }))
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