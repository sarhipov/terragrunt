/// certificates/wildcard/terragrunt.hcl
include "root" {
  path   = find_in_parent_folders()
  expose = true
}

include "certificates-common" {
  path = find_in_parent_folders("certificates.hcl")
}

inputs = {
  domain_name            = "*.topia.engineering"
  validation_method      = "DNS"
  create_route53_records = false

  tags = local.common_tags
}

locals {
  environment = include.root.locals.account_vars.locals.aws_account
  region      = include.root.locals.region_vars.locals.aws_region

  common_tags = {
    Terraform   = "Managed"
    Environment = local.environment
  }
}