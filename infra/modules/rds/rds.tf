
# locals {
#   services = {
#     order = {
#       namespace = "order"
#       database  = "orderdb"
#     }

#     user = {
#       namespace = "user"
#       database  = "userdb"
#     }

#     payment = {
#       namespace = "payment"
#       database  = "paymentdb"
#     }

#     product = {
#       namespace = "product"
#       database  = "productdb"
#     }
#   }
# }
# resource "aws_db_instance" "postgres" {
#   identifier = "${var.tags.environment}-postgres"

#   engine         = "postgres"
#   engine_version = "16.4"

#   instance_class = "db.r6g.large"

#   allocated_storage     = 20
#   max_allocated_storage = 1000

#   storage_type      = "gp3"
#   storage_encrypted = true

#   multi_az = true

#   username = "masteradmin"
#   password = random_password.master.result

#   publicly_accessible = false

#   backup_retention_period = 30

#   deletion_protection = true
#   skip_final_snapshot = true

#   copy_tags_to_snapshot = true

#   performance_insights_enabled = true

#   auto_minor_version_upgrade = true

#   db_subnet_group_name = aws_db_subnet_group.postgres.name

#   vpc_security_group_ids = [
#     aws_security_group.postgres.id
#   ]

#   tags = merge(
#     var.tags,
#     {
#       Name = "${var.tags.environment}-postgres"
#     }
#   )
# }

# resource "aws_security_group" "postgres" {
#   name        = "${var.tags.environment}-postgres"
#   description = "PostgreSQL access"
#   vpc_id      = var.vpc_id

#   tags = merge(
#     var.tags,
#     {
#       Name = "${var.tags.environment}-postgres"
#     }
#   )
# }

# resource "aws_vpc_security_group_ingress_rule" "postgres_from_eks" {
#   security_group_id = aws_security_group.postgres.id

#   referenced_security_group_id = var.eks_node_security_group_id

#   from_port   = 5432
#   to_port     = 5432
#   ip_protocol = "tcp"
# }

# resource "aws_vpc_security_group_egress_rule" "postgres_all" {
#   security_group_id = aws_security_group.postgres.id

#   cidr_ipv4   = "0.0.0.0/0"
#   ip_protocol = "-1"
# }

# resource "aws_secretsmanager_secret" "database" {
#   for_each = local.services

#   name = "/${var.tags.environment}/${each.key}/database"

#   recovery_window_in_days = 7

#   tags = var.tags
# }

# resource "random_password" "service" {
#   for_each = local.services

#   length  = 32
#   special = true
#   override_special = "!#$%&*()-_=+[]{}<>:?"
# }

# resource "aws_secretsmanager_secret_version" "database" {
#   for_each = local.services

#   secret_id = aws_secretsmanager_secret.database[each.key].id

#   secret_string = jsonencode({
#     host     = aws_db_instance.postgres.address
#     port     = 5432
#     database = each.value.database

#     username = "${each.key}_user"
#     password = random_password.service[each.key].result

#     sslmode = "require"
#   })
# }





locals {
  services = {
    order   = { db = "orderdb" }
    user    = { db = "userdb" }
    payment = { db = "paymentdb" }
    product = { db = "productdb" }
  }
}

resource "aws_db_instance" "postgres" {
  identifier = "${var.tags.environment}-postgres"

  engine         = "postgres"
  engine_version = "16.4"

  instance_class = "db.r6g.large"

  allocated_storage     = 20
  max_allocated_storage = 500

  username = "masteradmin"
  password = random_password.master.result

  publicly_accessible = false
  multi_az            = true
  deletion_protection = false

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.postgres.id]

  skip_final_snapshot = true
}

provider "postgresql" {
  host     = aws_db_instance.postgres.address
  port     = 5432
  username = "masteradmin"
  password = random_password.master.result
  sslmode  = "require"
}

resource "postgresql_database" "db" {
  for_each = local.services

  name  = each.value.db
  owner = "masteradmin"
}

resource "random_password" "service" {
  for_each = local.services

  length  = 32
  special = true
}

resource "postgresql_role" "user" {
  for_each = local.services

  name     = "${each.key}_user"
  login    = true
  password = random_password.service[each.key].result
}

resource "postgresql_grant" "access" {
  for_each = local.services

  database    = postgresql_database.db[each.key].name
  role        = postgresql_role.user[each.key].name
  object_type = "database"
  privileges  = ["ALL"]
}

resource "aws_secretsmanager_secret" "db" {
  for_each = local.services

  name = "/${var.tags.environment}/${each.key}/db"
}

resource "aws_secretsmanager_secret_version" "db" {
  for_each = local.services

  secret_id = aws_secretsmanager_secret.db[each.key].id

  secret_string = jsonencode({
    host     = aws_db_instance.postgres.address
    port     = 5432
    database = postgresql_database.db[each.key].name
    username = postgresql_role.user[each.key].name
    password = random_password.service[each.key].result
    sslmode  = "require"
  })
}