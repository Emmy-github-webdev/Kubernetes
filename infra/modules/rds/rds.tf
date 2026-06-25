# create PostgreSQL users

locals {
  services = {
    order   = { db = "orderdb" }
    user    = { db = "userdb" }
    payment = { db = "paymentdb" }
    product = { db = "productdb" }
  }
}

resource "random_password" "service" {
  for_each = local.services

  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# Store credentials
resource "aws_secretsmanager_secret" "service" {
  for_each = local.services

  name = "/${var.tags.environment}/${each.key}/db"
}

resource "aws_secretsmanager_secret" "postgres_master" {
  name = "/${var.tags.environment}/postgres/master"
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
  for_each = local.services

  secret_id = aws_secretsmanager_secret.service[each.key].id

  secret_string = jsonencode({
    database = each.value.db
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

  username = "masteradmin"
  password = random_password.master.result

  publicly_accessible = false

  db_subnet_group_name = aws_db_subnet_group.postgres.name

  vpc_security_group_ids = [
    aws_security_group.postgres.id
  ]
}