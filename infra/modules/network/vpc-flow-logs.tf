resource "aws_flow_log" "vpc_flow_logs" {
  log_destination      = var.cloudwatch_log_group_arn
  log_destination_type = "cloud-watch-logs"
  traffic_type         = "ALL"

  vpc_id       = aws_vpc.eks_vpc.id
  iam_role_arn = var.vpc_flow_logs_iam_role_arn

  max_aggregation_interval = 60

  tags = {
    Name = "${var.tags.project}-${var.tags.environment}-vpc-flowlogs"
  }
}