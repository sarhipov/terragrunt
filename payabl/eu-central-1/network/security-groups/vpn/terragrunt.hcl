/// security-groups/vpn/terragrunt.hcl
include "root" {
  path   = find_in_parent_folders()
  expose = true
}

include "security-groups-common" {
  path   = find_in_parent_folders("security-groups.hcl")
  expose = true
}

inputs = merge(
  include.security-groups-common.locals.common_inputs,
  {
    vpc_id = dependency.vpc.outputs.vpc_id

    egress_with_cidr_blocks = [
      {
        from_port   = -1
        to_port     = -1
        protocol    = "-1"
        description = "(Terraform)Allow all Egress traffic to ${dependency.vpc.outputs.name}"
        cidr_blocks = dependency.vpc.outputs.vpc_cidr_block
      }
    ]

    tags = local.common_tags
  }
)

locals {
  environment = include.root.locals.account_vars.locals.aws_account
  region      = include.root.locals.region_vars.locals.aws_region

  common_tags = {
    Terraform   = "Managed"
    Environment = local.environment
  }
}