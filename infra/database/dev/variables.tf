variable "environment" {
  description = "Defines the environment to provision the resurces"
  type        = string
  default     = "dev"
}

variable "aws_region" {
  type        = string
  description = "Defines the region where the resources are created"
  default     = "us-east-1"
}

variable "state_bucket" {
  type = string
}


# variable "services" {
#   type = map(object({
#     db = string
#   }))
# }