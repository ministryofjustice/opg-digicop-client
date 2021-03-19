variable "accounts" {
  type = map(
  object({
    account_id = string
    is_production = string
    name = string
  })
  )
}

locals {
  environment              = lower(terraform.workspace)
  capitalized_environment  = "${upper(substr(local.environment, 0, 1))}${substr(local.environment, 1, -1)}"
  service                  = "serve-opg"
  sirius_role              = var.SIRIUS_ROLE == "serve-assume-role-ci" ? "${var.SIRIUS_ROLE}-${local.environment}" : var.SIRIUS_ROLE

  account                 = contains(keys(var.accounts), local.environment) ? var.accounts[local.environment] : var.accounts["default"]
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

