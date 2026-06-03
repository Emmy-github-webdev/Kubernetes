
output "vpc_flow_logs_cloudwatch_loggroup_arn" {
  description = "CloudWatch log group for VPC flow logs"
  value       = aws_cloudwatch_log_group.eks_vpc_flow_logs.arn
}

output "kms_key_arn" {
  description = "ARN of the KMS key for CloudWatch Logs"
  value       = aws_kms_key.cloudwatch_logs.arn
}