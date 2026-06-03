resource "aws_eip" "eks_eip" {
  for_each = local.public_subnets
  domain   = "vpc"

  tags = {
    Name = "${var.tags.project}-${var.tags.environment}-eip-${each.key}"
  }
}