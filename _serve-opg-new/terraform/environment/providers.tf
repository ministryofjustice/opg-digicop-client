variable "DEFAULT_ROLE" {
  default = "serve-opg-ci"
}

variable "SIRIUS_ROLE" {
  default = "serve-assume-role-ci"
}

variable "SHARED_ROLE" {
  default = "serve-opg-ci"
}

provider "aws" {
  region = "eu-west-1"

  assume_role {
    role_arn     = "arn:aws:iam::${local.account.account_id}:role/${var.DEFAULT_ROLE}"
    session_name = "terraform-session"
  }
}

provider "aws" {
  region = "us-east-1"
  alias  = "us-east-1"

  assume_role {
    role_arn     = "arn:aws:iam::${local.account.account_id}:role/${var.DEFAULT_ROLE}"
    session_name = "terraform-session"
  }
}

provider "aws" {
  region = "eu-west-1"
  alias  = "management"

  assume_role {
    role_arn = "arn:aws:iam::${local.management_account_id}:role/${var.DEFAULT_ROLE}"
  }
}

provider "aws" {
  region = "eu-west-1"
  alias  = "sirius"

  assume_role {
    role_arn = "arn:aws:iam::${local.account.sirius_account}:role/${var.SIRIUS_ROLE}"
  }
}

terraform {
  backend "s3" {
    bucket         = "opg.terraform.state"
    key            = "serve-opg/terraform.tfstate"
    encrypt        = true
    region         = "eu-west-1"
    role_arn       = "arn:aws:iam::${local.management_account_id}:role/${var.SHARED_ROLE}"
    dynamodb_table = "remote_lock"
  }
}

