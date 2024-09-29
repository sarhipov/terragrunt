/// network/vpc/main/terragrunt.hcl
include "root" {
  path   = find_in_parent_folders()
  expose = true
}

include "vpc-common" {
  path = find_in_parent_folders("vpc.hcl")
}

# prevent_destroy = true

inputs = {
  name = local.vpc_name
  cidr = local.vpc_cidr
  azs  = local.azs

  #####################################################################################
  /// Public
  /// Access to Internet via IGW
  #####################################################################################
  public_subnets          = local.public_subnets
  public_subnet_names     = local.public_subnet_names
  map_public_ip_on_launch = true
  public_route_table_tags = {
    "Name" = "${local.vpc_name}-public-subnet-rt"
  }

  #####################################################################################
  /// Private
  /// Access to Internet via NAT GW
  #####################################################################################
  private_subnets      = local.private_subnets
  private_subnet_names = local.private_subnet_names

  #####################################################################################
  /// Intra
  /// no access to Internet
  #####################################################################################
  intra_subnets      = local.intra_subnets
  intra_subnet_names = local.intra_subnet_names
  intra_route_table_tags = {
    "Name" = "${local.vpc_name}-intra-subnet-rt"
  }

  #####################################################################################
  /// Databases
  /// database subnets
  #####################################################################################
  database_subnet_names              = local.database_subnet_names
  database_subnets                   = local.database_subnets
  create_database_subnet_route_table = true
  database_route_table_tags = {
    "Name" = "${local.vpc_name}-database-subnet-rt"
  }

  /// Internet GW
  create_igw = true # default true
  igw_tags = {
    Name = "${local.vpc_name}-igw"
  }

  /// NAT GW (check here for available options: https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest#nat-gateway-scenarios)
  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  /// Flow logs
  enable_flow_log       = false
  flow_log_traffic_type = "ALL"

  tags = local.common_tags
}

locals {
  environment = include.root.locals.account_vars.locals.aws_account
  region      = include.root.locals.region_vars.locals.aws_region

  ###########################################################################################
  /// Network
  ###########################################################################################
  vpc_name = "${basename(get_terragrunt_dir())}-vpc"
  vpc_cidr = "10.0.0.0/16"

  num_of_azs  = 3
  az_suffixes = ["a", "b", "c", "d", "e", "f"]
  azs         = [for i in range(local.num_of_azs) : "${local.region}${local.az_suffixes[i]}"]

  ###########################################################################################
  ///Subnets
  ###########################################################################################
  /// Public subnets
  public_subnets            = [for idx, az in local.azs : cidrsubnet(local.vpc_cidr, 8, idx + 0)]
  public_subnet_names       = [for az in local.azs : format("${local.public_subnet_name_prefix}-%s", az)]
  public_subnet_name_prefix = "public"

  /// Private subnets
  private_subnets            = [for idx, az in local.azs : cidrsubnet(local.vpc_cidr, 8, idx + 10)]
  private_subnet_names       = [for az in local.azs : format("${local.private_subnet_name_prefix}-%s", az)]
  private_subnet_name_prefix = "private"

  /// Intra subnets
  intra_subnets            = [for idx, az in local.azs : cidrsubnet(local.vpc_cidr, 8, idx + 20)]
  intra_subnet_names       = [for az in local.azs : format("${local.intra_subnet_name_prefix}-%s", az)]
  intra_subnet_name_prefix = "intra"

  // Database subnets
  database_subnets            = [for idx, az in local.azs : cidrsubnet(local.vpc_cidr, 8, idx + 30)]
  database_subnet_names       = [for az in local.azs : format("${local.database_subnet_name_prefix}-%s", az)]
  database_subnet_name_prefix = "database"


  common_tags = {
    Terraform   = "Managed"
    Environment = local.environment
  }
}