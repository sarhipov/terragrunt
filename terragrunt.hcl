/// root level terragrunt.hcl
locals {
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))
}

generate "provider" {
  path      = "providers.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
    provider "aws" {
      region = "${local.region_vars.locals.aws_region}"
    }
    EOF
}

generate "provider_version" {
  path      = "versions.tf"
  if_exists = "overwrite"
  contents  = <<EOF
    terraform {
      required_providers {
        aws = {
          source  = "hashicorp/aws"
          version = "~> 5.0"
        }
      }
    }
    EOF
}

remote_state {
  backend = "s3"
  config = {
    bucket         = "${local.account_vars.locals.aws_account}-terraform-state"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "${local.region_vars.locals.aws_region}"
    encrypt        = true
    dynamodb_table = "${local.account_vars.locals.aws_account}-terraform-locks"
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

download_dir                  = "${get_parent_terragrunt_dir()}/.terragrunt-cache"
terraform_version_constraint  = ">= 1.2.9"
terragrunt_version_constraint = ">= 0.67.5"

# iam_role = "arn:aws:iam::AWS_ACCOUNT_ID:role/IAM_ROLE_NAME" /// TODO