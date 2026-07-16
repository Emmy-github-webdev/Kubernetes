variable "environment" {
  description = "Defines the environment to provision the resurces"
  type        = string
  default     = "dev"
}

variable "project" {
  description = "Defines the project name"
  type        = string
  default     = "eks"
}

variable "region" {
  type        = string
  description = "Defines the region where the resources are created"
  default     = "us-east-1"
}