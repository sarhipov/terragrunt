/// elb/private-alb/terragrunt.hcl
include "root" {
  path   = find_in_parent_folders()
  expose = true
}

include "alb-common" {
  path   = find_in_parent_folders("alb.hcl")
  expose = true
}

inputs = merge(
  include.alb-common.locals.common_inputs,
  {
    vpc_id  = dependency.vpc.outputs.vpc_id
    subnets = dependency.vpc.outputs.private_subnets

    # Security Group
    security_groups = [dependency.alb-sg.outputs.security_group_id]

    listeners = {
      https = {
        port            = 443
        protocol        = "HTTPS"
        certificate_arn = dependency.wildcard_certificate.outputs.acm_certificate_arn

        forward = {
          target_group_key = "app-asg"
        }
      }
    }

    target_groups = {
      app-asg = {
        backend_protocol                  = "HTTPS"
        backend_port                      = 443
        target_type                       = "instance"
        deregistration_delay              = 5
        load_balancing_cross_zone_enabled = true
        create_attachment                 = false
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