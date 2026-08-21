variable "app_name" {
  description = "The name of the microservices application"
  type        = string
  default     = "ja-mics-ap"
}

variable "tags" {
  description = "Tags applied to the shared ECR repositories"
  type        = map(string)
  default     = {}
}