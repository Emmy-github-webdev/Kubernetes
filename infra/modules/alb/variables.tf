variable "tags" {
  description = "Global resources"
  type        = map(string)
  default     = {}
}

variable "domain_name" {
  description = "DNS name"
  type        = string
}