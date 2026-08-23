variable "tags" {
  description = "Global resources"
  type        = map(string)
  default     = {}
}

variable "eks_vpc_id" {
  description = "VPC ID for the EKS cluster"
  type        = string
}