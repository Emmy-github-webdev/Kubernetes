
output "vpc_flow_logs_cloudwatch_loggroup_arn" {
  description = "CloudWatch log group for VPC flow logs"
  value       = aws_cloudwatch_log_group.eks_vpc_flow_logs.arn
}