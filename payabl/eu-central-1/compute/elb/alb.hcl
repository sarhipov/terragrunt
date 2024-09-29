terraform {
  source = "tfr:///terraform-aws-modules/alb/aws//?version=9.11.0"
}

dependency "vpc" {
  config_path = "${get_terragrunt_dir()}/../../../network/vpc/main"
}

dependency "wildcard_certificate" {
  config_path = "${get_terragrunt_dir()}/../../../certificates/wildcard"
}

dependency "alb-sg" {
  config_path = "${get_terragrunt_dir()}/../../../network/security-groups/${basename(get_terragrunt_dir())}"
}

locals {
  common_inputs = {
    name                       = basename(get_terragrunt_dir())
    enable_deletion_protection = false # false during development / testing

    # Security Group
    create_security_group = false
  }
}