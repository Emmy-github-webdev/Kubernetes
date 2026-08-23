output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.eks_vpc.id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = [for subnet in values(aws_subnet.eks_public_subnets) : subnet.id]
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = [for subnet in values(aws_subnet.eks_private_subnets) : subnet.id]
}

# output "oidc_provider_arn" {
#   value = aws_iam_openid_connect_provider.eks_oidc_provider.arn
# }

# output "oidc_provider_url" {
#   value = aws_iam_openid_connect_provider.eks_oidc_provider.url
# }