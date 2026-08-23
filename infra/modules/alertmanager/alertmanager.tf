resource "aws_secretsmanager_secret" "alertmanager" {
  name                    = "${var.tags.environment}-alertmanager/notifications"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "alertmanager" {
  secret_id = aws_secretsmanager_secret.alertmanager.id

  secret_string = jsonencode({
    slack-webhook = var.slack_webhook
  })
}