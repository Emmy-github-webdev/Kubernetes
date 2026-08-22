data "aws_caller_identity" "current" {}

# VPC Flow Logs CloudWatch log group
resource "aws_cloudwatch_log_group" "eks_vpc_flow_logs" {
  name              = "/aws/vpc/flowlogs/${var.tags.project}-${var.tags.environment}"
  retention_in_days = 365
  kms_key_id        = aws_kms_key.cloudwatch_logs.arn
  tags = {
    Name = "/aws/vpc/flowlogs/${var.tags.project}-${var.tags.environment}"
  }
}

resource "aws_kms_key" "cloudwatch_logs" {
  description         = "KMS key for CloudWatch Log Groups"
  enable_key_rotation = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EnableRootPermissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },

      {
        Sid    = "AllowCloudWatchLogsUseOfKey"
        Effect = "Allow"
        Principal = {
          Service = "logs.amazonaws.com"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*"
      }
    ]
  })

  tags = {
    Name = "${var.tags.project}-${var.tags.environment}-kms-cloudwatch-logs"
  }
}

resource "aws_kms_alias" "cloudwatch_logs" {
  name          = "alias/cloudwatch-logs-${var.tags.environment}"
  target_key_id = aws_kms_key.cloudwatch_logs.key_id
}