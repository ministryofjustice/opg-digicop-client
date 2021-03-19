data "aws_secretsmanager_secret" "database_password" {
  name = "db_password"
}

data "aws_secretsmanager_secret_version" "database_password" {
  secret_id = data.aws_secretsmanager_secret.database_password.id
}

data "aws_secretsmanager_secret" "public_api_password" {
  name = local.account.sirius_api_email
}

data "aws_secretsmanager_secret" "notification_api_key" {
  name = "notification_api_key"
}

data "aws_secretsmanager_secret" "os_places_api_key" {
  name = "os_places_api_key"
}

data "aws_secretsmanager_secret" "symfony_app_secret" {
  name = "symfony_app_secret"
}

data "aws_secretsmanager_secret" "behat_password" {
  name = "behat_password"
}