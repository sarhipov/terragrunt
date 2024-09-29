# account.hcl

locals {
  aws_account = basename(get_terragrunt_dir())
}
