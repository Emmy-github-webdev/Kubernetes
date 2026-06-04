locals {
  interface_endpoints = toset([
    "ecr.api",
    "ecr.dkr",
    "sts",
    "logs",
  ])
}

resource "aws_vpc_endpoint" "interface" {
  for_each = local.interface_endpoints

  vpc_id            = aws_vpc.eks_vpc.id
  service_name      = "com.amazonaws.${var.tags.region}.${each.value}"
  vpc_endpoint_type = "Interface"
  subnet_ids        = values(aws_subnet.eks_private_subnets)[*].id
  # security_group_ids  = [aws_security_group.vpce.id]
  private_dns_enabled = true

  tags = {
    Name = "${var.cluster_name}-${replace(each.value, ".", "-")}"
  }
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.eks_vpc.id
  service_name      = "com.amazonaws.${var.tags.region}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = [
    for rt in aws_route_table.eks_private_rt : rt.id
  ]

  tags = {
    Name = "${var.cluster_name}-s3"
  }
}

resource "aws_security_group" "vpce" {
  name   = "${var.cluster_name}-vpce"
  vpc_id = aws_vpc.eks_vpc.id

  ingress {
    description     = "HTTPS from EKS nodes"
    protocol        = "tcp"
    from_port       = 443
    to_port         = 443
    security_groups = [var.sg_eks_nodes_id]
  }

  egress {
    description     = "HTTPS to EKS nodes"
    protocol        = "tcp"
    from_port       = 443
    to_port         = 443
    security_groups = [var.sg_eks_nodes_id]
  }
}