/// security-groups.hcl
terraform {
  source = "tfr:///terraform-aws-modules/security-group/aws//?version=5.1.2"
}

dependency "vpc" {
  config_path = "${get_terragrunt_dir()}/../../vpc/main"
}

locals {
  common_inputs = {
    name            = "${basename(get_terragrunt_dir())}-sg"
    description     = "(Terraform)Security group for ${basename(get_terragrunt_dir())}"
    use_name_prefix = false
  }
}