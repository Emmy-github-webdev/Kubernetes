output "endpoint" {
  value = aws_db_instance.postgres.address
}

output "port" {
  value = aws_db_instance.postgres.port
}

output "master_secret_arn" {
  value = aws_secretsmanager_secret.postgres_master.arn
}

output "service_secret_arns" {
  value = {
    for k, v in aws_secretsmanager_secret.service :
    k => v.arn
  }
}

output "security_group_id" {
  value = aws_security_group.postgres.id
}

output "db_identifier" {
  value = aws_db_instance.postgres.identifier
}