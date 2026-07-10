# Redis security group
resource "aws_security_group" "redis" {
  name   = "${var.tags.environment}-redis"
  vpc_id = var.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "redis_from_eks" {
  security_group_id            = aws_security_group.redis.id
  referenced_security_group_id = var.eks_node_security_group_id

  from_port   = 6379
  to_port     = 6379
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "redis_all" {
  security_group_id = aws_security_group.redis.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}

# Elasticache subnet group
resource "aws_elasticache_subnet_group" "redis" {
  name       = "${var.tags.environment}-redis"
  subnet_ids = var.private_subnet_ids
}

# Redis cluster
resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "${var.tags.environment}-redis"
  engine               = "redis"
  node_type            = "cache.t4g.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis7"

  subnet_group_name  = aws_elasticache_subnet_group.redis.name
  security_group_ids = [aws_security_group.redis.id]
}

# Store Redis connection details in AWS Secrets Manager
resource "aws_secretsmanager_secret" "redis" {
  name = "/${var.tags.environment}/redis"
}

resource "aws_secretsmanager_secret_version" "redis" {
  secret_id = aws_secretsmanager_secret.redis.id

  secret_string = jsonencode({
    host = aws_elasticache_cluster.redis.cache_nodes[0].address
    port = 6379
  })
}