variable "environment" {}

variable "state_bucket" {}

variable "aws_region" {}

variable "services" {
  type = map(object({
    db = string
  }))
}