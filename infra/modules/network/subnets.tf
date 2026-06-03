locals {
  public_subnets = {
    for i, az in var.azs : az => var.public_subnet_cidrs[i]
  }

  private_subnets = {
    for i, az in var.azs : az => var.private_subnet_cidrs[i]
  }
}

resource "aws_subnet" "eks_public_subnets" {
  for_each                = local.public_subnets
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = each.value
  availability_zone       = each.key
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.tags.project}-${var.tags.environment}-public-subnet-${each.key}"
  }
}


resource "aws_subnet" "eks_private_subnets" {
  for_each                = local.private_subnets
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = each.value
  availability_zone       = each.key
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.tags.project}-${var.tags.environment}-private-subnet-${each.key}"
  }
}