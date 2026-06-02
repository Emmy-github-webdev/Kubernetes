variable "tags" {
  description = "Global resources"
  type        = map(string)
  default     = {}
}

variable "vpc_flow_logs_arn" {
  description = "IAM Role ARN for VPC flow logs"
  type        = string
}