data "aws_secretsmanager_secret" "slack_url" {
  name = "serve_slack_url"
}

data "aws_secretsmanager_secret_version" "slack_url" {
  secret_id = data.aws_secretsmanager_secret.slack_url.id
}

data "aws_secretsmanager_secret" "behat_password" {
  name = "behat_password"
}

resource "aws_secretsmanager_secret" "database_password" {
  name        = "db_password"
  description = "Database password for serve opg"
  tags        = local.default_tags
}