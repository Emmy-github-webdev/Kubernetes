variable "tags" {
  description = "Global resources"
  type        = map(string)
  default     = {}
}

variable "grafana_admin_password" {
  type      = string
  sensitive = true
}