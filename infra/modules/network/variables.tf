variable "tags" {
  description = "Global resources"
  type        = map(string)
  default     = {}
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "azs" {
  description = "List of availability zones for subnets"
  type        = list(string)
}

# Public Subnet
variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
}

# Private Subnet
variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
}

variable "cloudwatch_log_group_arn" {
  description = "ARN of the CloudWatch log group for VPC flow logs"
  type        = string
}

variable "vpc_flow_logs_iam_role_arn" {
  description = "IAM Role ARN for VPC flow logs"
  type        = string
}