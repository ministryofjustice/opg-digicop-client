variable "accounts" {
  type = map(
  object({
    account_id = string
    aurora_serverless = bool
    aurora_instance_count = number
    bucket_name = string
    behat_controller = number
    dc_gtm = string
    dns_prefix = string
    deletion_protection = bool
    fixtures_enabled = string
    is_production = string
    name = string
    psql_engine_version = string
    sirius_account = string
    sirius_api = string
    sirius_api_email = string
    sirius_bucket = string
    sirius_key_alias = string
  })
  )
}

locals {
  environment              = lower(terraform.workspace)
  capitalized_environment  = "${upper(substr(local.environment, 0, 1))}${substr(local.environment, 1, -1)}"
  service                  = "serve-opg"
  sirius_role              = var.SIRIUS_ROLE == "serve-assume-role-ci" ? "${var.SIRIUS_ROLE}-${local.environment}" : var.SIRIUS_ROLE

  account                 = contains(keys(var.accounts), local.environment) ? var.accounts[local.environment] : var.accounts["default"]
  dns_prefix = local.account.name == "default" ? "serve.${local.environment}" : local.account.dns_prefix
  management_account_id = "311462405659"

  default_tags = {
    business-unit          = "OPG"
    application            = "Serve OPG"
    environment-name       = terraform.workspace
    owner                  = "opgallocations@digital.justice.gov.uk"
    infrastructure-support = "OPG WebOps: opgteam@digital.justice.gov.uk"
    is-production          = local.account.is_production
  }
}

