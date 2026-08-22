variable "tags" {
  description = "Global resources"
  type        = map(string)
  default     = {}
}

variable "slack_webhook" {
  description = "Slack webhook URL for Alertmanager notifications"
  type        = string
  sensitive   = true
}