variable "tags" {
  description = "Global resources"
  type        = map(string)
  default     = {}
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "oidc_provider_arn" {
  type = string
}

variable "oidc_issuer_url" {
  type = string
}