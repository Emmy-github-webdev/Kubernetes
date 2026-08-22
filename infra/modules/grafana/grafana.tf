
resource "aws_secretsmanager_secret" "grafana_admin" {
  name = "${var.tags.environment}-grafana/admin"

  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "grafana_admin" {
  secret_id = aws_secretsmanager_secret.grafana_admin.id

  secret_string = jsonencode({
    username = "admin"
    password = var.grafana_admin_password
  })
}