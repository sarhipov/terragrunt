/// compute/asg/app/terragrunt.hcl
include "asg-common" {
  path   = find_in_parent_folders("asg.hcl")
  expose = true
}

include "root" {
  path   = find_in_parent_folders()
  expose = true
}


dependency "private-alb" {
  config_path = "${get_terragrunt_dir()}/../../../compute/elb/private-alb"
}

inputs = merge(
  include.asg-common.locals.common_inputs,
  {
    vpc_zone_identifier = dependency.vpc.outputs.intra_subnets
    security_groups     = [dependency.security-group.outputs.security_group_id]
    key_name            = dependency.ssh-keys.outputs.key_pair_name

    traffic_source_attachments = {
      private-alb = {
        traffic_source_identifier = dependency.private-alb.outputs.target_groups.app-asg.arn
        traffic_source_type       = "elbv2"
      }
    }

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