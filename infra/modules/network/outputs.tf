output "vpc_id" {
  description = "The ID of the VPC"
  value = aws_vpc.eks_vpc.id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value = aws_subnet.eks_public_subnets[*].id
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value = aws_subnet.eks_private_subnets[*].id
}