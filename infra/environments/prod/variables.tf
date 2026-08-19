variable "environment" {
  description = "Defines the environment to provision the resurces"
  type        = string
  default     = "prod"
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

variable "grafana_admin_password" {
  type      = string
  sensitive = true
}
variable "slack_webhook" {
  description = "Slack webhook URL for Alertmanager notifications"
  type        = string
  sensitive   = true
}