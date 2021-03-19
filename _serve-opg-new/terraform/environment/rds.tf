module "api_aurora" {
  source                        = "./aurora"
  count                         = 1
  aurora_serverless             = local.account.aurora_serverless
  account_id                    = data.aws_caller_identity.current.account_id
  apply_immediately             = local.account.deletion_protection ? false : true
  cluster_identifier            = "serveopg"
  db_subnet_group_name          = "${local.account.name}-db-subnet-group"
  deletion_protection           = local.account.deletion_protection ? true : false
  database_name                 = "serveopg"
  engine_version                = local.account.psql_engine_version
  master_username               = "serveopgadmin"
  master_password               = data.aws_secretsmanager_secret_version.database_password.secret_string
  instance_count                = local.account.aurora_instance_count
  instance_class                = "db.t3.medium"
  kms_key_id                    = data.aws_kms_key.rds.arn
  replication_source_identifier = ""
  skip_final_snapshot           = local.account.deletion_protection ? false : true
  vpc_security_group_ids        = [aws_security_group.database.id]
  tags                          = local.default_tags
  log_group                     = aws_cloudwatch_log_group.api_cluster
}

locals {
  db = {
    endpoint = module.api_aurora[0].endpoint
    port     = module.api_aurora[0].port
    name     = module.api_aurora[0].name
    username = module.api_aurora[0].master_username
  }
}

// DB Log group
resource "aws_cloudwatch_log_group" "api_cluster" {
  name              = "/aws/rds/cluster/serveopg-${local.environment}/postgresql"
  retention_in_days = 180
  tags              = local.default_tags
}

// DB KMS key
data "aws_kms_key" "rds" {
  key_id = "alias/aws/rds"
}

// DB Security Group
resource "aws_security_group" "database" {
  name   = "${local.environment}-serve-opg-db"
  vpc_id = data.aws_vpc.vpc.id
  tags   = local.default_tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "database_tcp_in" {
  protocol                 = "tcp"
  from_port                = local.db.port
  to_port                  = local.db.port
  security_group_id        = aws_security_group.database.id
  source_security_group_id = aws_security_group.ecs_service.id
  type                     = "ingress"
}

data "aws_caller_identity" "current" {}
