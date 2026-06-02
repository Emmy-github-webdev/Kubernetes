resource "aws_eip" "eks_eip" {
  for_each = local.public_subnets
  domain = aws_vpc.eks_vpc.id

  tags = {
    Name = "${var.tags.project}-${var.tags.environment}-eip-${each.key}"
  }
}