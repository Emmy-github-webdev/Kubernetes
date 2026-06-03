output "vpc_flow_logs_iam_role_arn" {
  description = "IAM Role ARN for VPC flow logs"
  value       = aws_iam_role.vpc_flow_logs_role.arn
}