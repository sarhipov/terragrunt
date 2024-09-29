/// security-groups/aurora-db/terragrunt.hcl
include "root" {
  path   = find_in_parent_folders()
  expose = true
}

include "security-groups-common" {
  path   = find_in_parent_folders("security-groups.hcl")
  expose = true
}

dependency "app-node-sg" {
  config_path = "${get_terragrunt_dir()}/../app-node"
}

dependency "vpn-sg" {
  config_path = "${get_terragrunt_dir()}/../vpn"
}

inputs = merge(
  include.security-groups-common.locals.common_inputs,
  {
    vpc_id = dependency.vpc.outputs.vpc_id

    ingress_with_cidr_blocks = [
      {
        from_port                = 5432
        to_port                  = 5432
        protocol                 = "tcp"
        description              = "(Terraform)Allow HTTPs from private-alb"
        source_security_group_id = dependency.app-node-sg.outputs.security_group_id
      },
      {
        from_port                = 5432
        to_port                  = 5432
        protocol                 = "tcp"
        description              = "(Terraform)Allow HTTPs from private-alb"
        source_security_group_id = dependency.vpn-sg.outputs.security_group_id
      },
    ]
    egress_with_cidr_blocks = [
      {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        description = "(Terraform)Allow all Egress traffic to ${dependency.vpc.outputs.name}"
        cidr_blocks = dependency.vpc.outputs.vpc_cidr_block
      }
    ]
  }
)