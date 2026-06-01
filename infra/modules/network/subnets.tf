resource "aws_subnet" "eks_public_subnets" {
  count = length(var.azs)
  vpc_id = aws_vpc.eks_vpc.id
  cidr_block = var.public_subnet_cidrs[count.index]
  availability_zone = var.azs[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.tags.project}-${var.tags.environment}-public-subnet-${count.index + 1}"
  }
}


resource "aws_subnet" "eks_private_subnets" {
  count = length(var.azs)
  vpc_id = aws_vpc.eks_vpc.id
  cidr_block = var.private_subnet_cidrs[count.index]
  availability_zone = var.azs[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.tags.project}-${var.tags.environment}-private-subnet-${count.index + 1}"
  }
}