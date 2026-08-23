output "db_endpoint" {
  value = module.rds.endpoint
}

output "db_port" {
  value = module.rds.port
}

output "master_secret_arn" {
  value = module.rds.master_secret_arn
}

output "service_secret_arns" {
  value = module.rds.service_secret_arns
}