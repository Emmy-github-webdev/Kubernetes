# VPC Flow Logs CloudWatch log group
resource "aws_cloudwatch_log_group" "eks_vpc_flow_logs" {
  name              = "/aws/vpc/flowlogs/${var.tags.project}-${var.tags.environment}"
  retention_in_days = 7

  tags = {
    Name = "/aws/vpc/flowlogs/${var.tags.project}-${var.tags.environment}"
  }
}
