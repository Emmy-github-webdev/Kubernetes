# Provider
# provider "postgresql" {
#   host            = aws_db_instance.postgres.address
#   port            = 5432
#   database        = "postgres"
#   username        = "masteradmin"
#   password        = random_password.master.result
#   sslmode         = "require"
# }

# create PostgreSQL users

# locals {
#   services = {
#     order   = { db = "orderdb" }
#     user    = { db = "userdb" }
#     payment = { db = "paymentdb" }
#     product = { db = "productdb" }
#   }
# }

resource "random_password" "service" {
  for_each = var.services

  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "random_password" "master" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# Store credentials
resource "aws_secretsmanager_secret" "service" {
  for_each = var.services

  name                    = "/${var.tags.environment}/${each.key}/db"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret" "postgres_master" {
  name                    = "/${var.tags.environment}/postgres/master"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "postgres_master" {

  secret_id = aws_secretsmanager_secret.postgres_master.id

  secret_string = jsonencode({
    host     = aws_db_instance.postgres.address
    port     = 5432
    username = "masteradmin"
    password = random_password.master.result
  })
}

resource "aws_secretsmanager_secret_version" "service" {
  for_each = var.services

  secret_id = aws_secretsmanager_secret.service[each.key].id

  secret_string = jsonencode({
    database = var.services
    host     = aws_db_instance.postgres.address
    port     = 5432
    username = "${each.key}_user"
    password = random_password.service[each.key].result
  })
}

resource "aws_security_group" "postgres" {
  name   = "${var.tags.environment}-postgres"
  vpc_id = var.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "postgres_from_eks" {

  security_group_id = aws_security_group.postgres.id

  referenced_security_group_id = var.eks_node_security_group_id

  from_port   = 5432
  to_port     = 5432
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "postgres_all" {

  security_group_id = aws_security_group.postgres.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}

resource "aws_db_subnet_group" "postgres" {

  name = "${var.tags.environment}-postgres"

  subnet_ids = var.private_subnet_ids
}

resource "aws_db_instance" "postgres" {

  identifier = "${var.tags.environment}-postgres"

  engine         = "postgres"
  engine_version = "16.4"

  instance_class = "db.r6g.large"

  allocated_storage     = 20
  max_allocated_storage = 50
  storage_type          = "gp3"

  username = "masteradmin"
  password = random_password.master.result

  publicly_accessible = false
  multi_az            = true
  deletion_protection = false

  db_subnet_group_name   = aws_db_subnet_group.postgres.name
  vpc_security_group_ids = [aws_security_group.postgres.id]

  skip_final_snapshot = true
}

# # Postgresql DB
# resource "postgresql_database" "service" {
#   for_each = local.services

#   name = each.value.db

#   owner = "${each.key}_user"

#   depends_on = [
#     postgresql_role.service
#   ]
# }

# # Service users
# resource "postgresql_role" "service" {
#   for_each = local.services

#   name     = "${each.key}_user"
#   login    = true
#   password = random_password.service[each.key].result

#   depends_on = [
#     aws_db_instance.postgres
#   ]
# }

# # Grant privileges to service users
# resource "postgresql_grant" "service_database" {
#   for_each = local.services

#   database    = each.value.db
#   role        = "${each.key}_user"
#   object_type = "database"
#   privileges  = ["CONNECT"]

#   depends_on = [
#     postgresql_database.service
#   ]
# }

# # Grant privileges to service users on all tables in the database
# resource "postgresql_grant" "service_schema" {
#   for_each = local.services

#   database    = each.value.db
#   role        = "${each.key}_user"
#   schema      = "public"
#   object_type = "schema"
#   privileges  = ["USAGE", "CREATE"]

#   depends_on = [
#     postgresql_database.service
#   ]
# }