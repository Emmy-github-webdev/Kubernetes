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

variable "eks_vpc_id" {
  description = "VPC ID for the EKS cluster"
  type        = string
}
