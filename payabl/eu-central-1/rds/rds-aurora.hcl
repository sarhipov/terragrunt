/// rds-aurora.hcl
terraform {
  source = "tfr:///terraform-aws-modules/rds-aurora/aws//?version=9.9.1"
}

dependency "vpc" {
  config_path = "${get_terragrunt_dir()}/../../network/vpc/main"
}