/// region.hcl
locals {
  aws_region = basename(get_terragrunt_dir())
}
