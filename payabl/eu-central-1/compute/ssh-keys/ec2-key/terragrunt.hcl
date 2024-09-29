/// compute/ssh-keys/key-pair
terraform {
  source = "tfr:///terraform-aws-modules/key-pair/aws//?version=2.0.3"

  after_hook "save_private_key" {
    commands = ["apply"]
    execute = [
      "sh", "-c",
      "terraform output -raw private_key_pem > ${get_terragrunt_dir()}/${local.ssh_key_name}.pem && chmod 600 ${get_terragrunt_dir()}/${local.ssh_key_name}.pem"
    ]
  }
}

include "root" {
  path   = find_in_parent_folders()
  expose = true
}

inputs = {
  key_name           = local.ssh_key_name
  create_private_key = true

  tags = local.common_tags
}

locals {
  environment = include.root.locals.account_vars.locals.aws_account
  region      = include.root.locals.region_vars.locals.aws_region

  ssh_key_name = "${include.root.locals.account_vars.locals.aws_account}_${include.root.locals.region_vars.locals.aws_region}_ssh-key"

  common_tags = {
    Terraform   = "Managed"
    Environment = local.environment
  }
}