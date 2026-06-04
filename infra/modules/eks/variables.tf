variable "tags" {
  description = "Global resources"
  type        = map(string)
  default     = {}
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for the EKS cluster"
  type        = list(string)
}

variable "kms_key_arn" {
  description = "ARN of the KMS key for encrypting EKS secrets"
  type        = string
}

variable "cluster_security_group_id" {
  description = "Security Group ID for EKS Cluster control plane"
  type        = string
}