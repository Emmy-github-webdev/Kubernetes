terraform {
  required_providers {
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "~> 1.26"
    }
  }
}

locals {
  services = {
    order = {
      namespace = "order"
      database  = "orderdb"
    }

    user = {
      namespace = "user"
      database  = "userdb"
    }

    payment = {
      namespace = "payment"
      database  = "paymentdb"
    }

    product = {
      namespace = "product"
      database  = "productdb"
    }
  }
}

resource "random_password" "master" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "random_password" "service" {
  for_each = local.services

  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_security_group" "postgres" {

  name   = "${var.tags.environment}-postgres"
  vpc_id = var.vpc_id
}

resource "aws_security_group_rule" "postgres_ingress" {

  type = "ingress"

  from_port = 5432
  to_port   = 5432
  protocol  = "tcp"

  source_security_group_id = var.eks_node_security_group_id

  security_group_id = aws_security_group.postgres.id
}

resource "aws_security_group_rule" "postgres_egress" {

  type = "egress"

  from_port = 0
  to_port   = 0
  protocol  = "-1"

  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.postgres.id
}

resource "aws_db_subnet_group" "postgres" {

  name       = "${var.tags.environment}-postgres"
  subnet_ids = var.private_subnet_ids
}

resource "aws_db_instance" "postgres" {

  identifier = "${var.tags.environment}-postgres"

  engine         = "postgres"
  engine_version = "16.4"

  instance_class = "db.r6g.large"

  allocated_storage = 100

  storage_type      = "gp3"
  storage_encrypted = true

  multi_az = true

  username = "masteradmin"
  password = random_password.master.result

  publicly_accessible = false

  backup_retention_period = 30

  deletion_protection = false

  skip_final_snapshot = true

  db_subnet_group_name = aws_db_subnet_group.postgres.name

  vpc_security_group_ids = [
    aws_security_group.postgres.id
  ]
}

provider "postgresql" {

  host = aws_db_instance.postgres.address

  port = 5432

  username = "masteradmin"
  password = random_password.master.result

  sslmode = "require"
}

resource "postgresql_database" "service" {

  for_each = local.services

  name = each.value.database
}

resource "postgresql_role" "service" {

  for_each = local.services

  name = "${each.key}_user"

  login = true

  password = random_password.service[each.key].result
}

resource "postgresql_grant" "database" {

  for_each = local.services

  database = postgresql_database.service[each.key].name

  role = postgresql_role.service[each.key].name

  object_type = "database"

  privileges = [
    "CONNECT",
    "CREATE",
    "TEMPORARY"
  ]
}

resource "aws_security_group" "redis" {

  name   = "${var.tags.environment}-redis"
  vpc_id = var.vpc_id
}

resource "aws_security_group_rule" "redis_ingress" {

  type = "ingress"

  from_port = 6379
  to_port   = 6379

  protocol = "tcp"

  source_security_group_id = var.eks_node_security_group_id

  security_group_id = aws_security_group.redis.id
}

resource "aws_elasticache_subnet_group" "redis" {

  name = "${var.tags.environment}-redis"

  subnet_ids = var.private_subnet_ids
}

resource "aws_elasticache_replication_group" "redis" {

  replication_group_id = "${var.tags.environment}-redis"

  description = "Shared Redis"

  engine = "redis"

  node_type = "cache.t4g.small"

  automatic_failover_enabled = true

  multi_az_enabled = true

  num_cache_clusters = 2

  subnet_group_name = aws_elasticache_subnet_group.redis.name

  security_group_ids = [
    aws_security_group.redis.id
  ]

  transit_encryption_enabled = true

  at_rest_encryption_enabled = true
}

resource "aws_secretsmanager_secret" "database" {

  for_each = local.services

  name = "/${var.tags.environment}/${each.key}-service/database"
}

resource "aws_secretsmanager_secret_version" "database" {

  for_each = local.services

  secret_id = aws_secretsmanager_secret.database[each.key].id

  secret_string = jsonencode({
    host     = aws_db_instance.postgres.address
    port     = 5432
    dbname   = each.value.database
    username = postgresql_role.service[each.key].name
    password = random_password.service[each.key].result
  })
}

resource "aws_secretsmanager_secret" "redis" {

  name = "/${var.tags.environment}/redis"
}

resource "aws_secretsmanager_secret_version" "redis" {

  secret_id = aws_secretsmanager_secret.redis.id

  secret_string = jsonencode({
    host = aws_elasticache_replication_group.redis.primary_endpoint_address
    port = 6379
  })
}

data "aws_iam_policy_document" "assume_role" {

  for_each = local.services

  statement {

    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]

    effect = "Allow"

    principals {

      type = "Federated"

      identifiers = [
        var.eks_oidc_provider_arn
      ]
    }

    condition {

      test = "StringEquals"

      variable = "${replace(var.eks_oidc_provider_url, "https://", "")}:sub"

      values = [
        "system:serviceaccount:${each.value.namespace}:${each.key}-service"
      ]
    }
  }
}

resource "aws_iam_role" "service" {

  for_each = local.services

  name = "${var.tags.environment}-${each.key}-service-irsa"

  assume_role_policy = data.aws_iam_policy_document.assume_role[each.key].json
}

resource "aws_iam_policy" "service" {

  for_each = local.services

  name = "${var.tags.environment}-${each.key}-secret-access"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "secretsmanager:GetSecretValue"
        ]

        Resource = [
          aws_secretsmanager_secret.database[each.key].arn,
          aws_secretsmanager_secret.redis.arn
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "service" {

  for_each = local.services

  role = aws_iam_role.service[each.key].name

  policy_arn = aws_iam_policy.service[each.key].arn
}