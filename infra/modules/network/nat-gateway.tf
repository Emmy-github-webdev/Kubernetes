resource "aws_nat_gateway" "eks_nat" {
  for_each = local.public_subnets

  allocation_id = aws_eip.eks_eip[each.key].id
  subnet_id     = aws_subnet.eks_public_subnets[each.key].id

  depends_on = [aws_internet_gateway.eks_igw]

  tags = {
    Name = "${var.tags.project}-${var.tags.environment}-nat-${each.key}"
  }
}