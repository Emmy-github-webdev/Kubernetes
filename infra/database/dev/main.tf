data "terraform_remote_state" "infra" {

  backend = "s3"

  config = {

    bucket = var.state_bucket

    key = "${var.environment}/infrastructure.tfstate"

    region = var.aws_region

  }

}


data "aws_secretsmanager_secret_version" "master" {

  secret_id = data.terraform_remote_state.infra.outputs.master_secret_arn

}

data "aws_secretsmanager_secret_version" "service" {
  for_each = data.terraform_remote_state.infra.outputs.service_secret_arns

  secret_id = each.value
}


# Provider
provider "postgresql" {

  host = data.terraform_remote_state.infra.outputs.db_endpoint

  port = data.terraform_remote_state.infra.outputs.db_port

  database = "dev-postgres"

  username = jsondecode(
    data.aws_secretsmanager_secret_version.master.secret_string
  ).username

  password = jsondecode(
    data.aws_secretsmanager_secret_version.master.secret_string
  ).password

  sslmode = "require"

}

# Service users
resource "postgresql_role" "service" {

  for_each = var.services

  name = "${each.key}_user"

  login = true

  password = jsondecode(
    data.aws_secretsmanager_secret_version.service[each.key].secret_string
  ).password

}

# Postgresql DB
resource "postgresql_database" "service" {

  for_each = local.services

  name = each.value.db

  owner = postgresql_role.service[each.key].name

}


# Grant privileges to service users
resource "postgresql_grant" "service_database" {
  for_each = local.services

  database    = each.value.db
  role        = "${each.key}_user"
  object_type = "database"
  privileges  = ["CONNECT"]

  depends_on = [
    postgresql_database.service
  ]
}

# Grant privileges to service users on all tables in the database
resource "postgresql_grant" "service_schema" {
  for_each = local.services

  database    = each.value.db
  role        = "${each.key}_user"
  schema      = "public"
  object_type = "schema"
  privileges  = ["USAGE", "CREATE"]

  depends_on = [
    postgresql_database.service
  ]
}