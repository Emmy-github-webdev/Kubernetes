resource "aws_route_table" "eks_public_rt" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eks_igw.id
  }
}

resource "aws_route_table_association" "eks_public_rt_assoc" {
  for_each = local.public_subnets

  subnet_id      = aws_subnet.eks_public_subnets[each.key].id
  route_table_id = aws_route_table.eks_public_rt.id
}

resource "aws_route_table" "eks_private_rt" {
  for_each = local.private_subnets
  vpc_id   = aws_vpc.eks_vpc.id

  tags = {
    Name = "${var.tags.project}-${var.tags.environment}-private-rt-${each.key}"
  }
}

# Default Routes to NAT Gateways
resource "aws_route" "eks_private_nat" {
  for_each = local.private_subnets

  route_table_id         = aws_route_table.eks_private_rt[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.eks_nat[each.key].id
}

resource "aws_route_table_association" "eks_private_rt_assoc" {
  for_each = local.private_subnets

  subnet_id      = aws_subnet.eks_private_subnets[each.key].id
  route_table_id = aws_route_table.eks_private_rt[each.key].id
}