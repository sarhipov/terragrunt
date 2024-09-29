/// vpn/vpn-endpoint/terragrunt.hcl
terraform {
  source = "${get_parent_terragrunt_dir()}/modules/vpn-endpoint"
}

include "root" {
  path   = find_in_parent_folders()
  expose = true
}

dependency "vpc" {
  config_path = "${get_terragrunt_dir()}/../../vpc/main"
}

dependency "wildcard_certificate" {
  config_path = "${get_terragrunt_dir()}/../../../certificates/wildcard/"
}

dependency "vpn-sg" {
  config_path = "${get_terragrunt_dir()}/../../../network/security-groups/vpn"
}

inputs = {
  description            = "vpn endpoint"
  vpc_id                 = dependency.vpc.outputs.vpc_id
  vpc_cidr               = dependency.vpc.outputs.vpc_cidr_block
  vpn_subnets            = dependency.vpc.outputs.public_subnets
  server_certificate_arn = dependency.wildcard_certificate.outputs.acm_certificate_arn
  client_cidr_block      = "100.64.0.0/22"
  security_group_ids     = [dependency.vpn-sg.outputs.security_group_id]
  # dns_servers            = var.dns_servers

  tags = {
    "Name" = "vpn-endpoint"
  }
}