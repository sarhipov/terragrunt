/// rds/aurora/terragrunt.hcl
include "root" {
  path   = find_in_parent_folders()
  expose = true
}

include "rds-aurora-common" {
  path = find_in_parent_folders("rds-aurora.hcl")
}

dependency "aurora-db-sg" {
  config_path = "${get_terragrunt_dir()}/../../network/security-groups/aurora-db"
}

inputs = {
  name           = "${basename(get_terragrunt_dir())}-db-postgres"
  engine         = "aurora-postgresql"
  engine_version = "15.4"
  engine_mode    = "provisioned"
  instance_class = "db.r6g.large"

  db_cluster_parameter_group_use_name_prefix = false
  db_parameter_group_use_name_prefix         = false

  /// Network
  vpc_id                 = dependency.vpc.outputs.vpc_id
  availability_zones     = dependency.vpc.outputs.azs
  db_subnet_group_name   = "${basename(get_terragrunt_dir())}-subnet-group"
  create_db_subnet_group = true
  subnets                = dependency.vpc.outputs.database_subnets

  /// Security
  create_security_group  = false
  vpc_security_group_ids = [dependency.aurora-db-sg.outputs.security_group_id]

  /// Credentials
  master_username                                        = "postgres"
  manage_master_user_password_rotation                   = true
  master_user_password_rotation_automatically_after_days = 30

  /// Storage
  storage_encrypted = true

  /// Monitoring
  create_monitoring_role = false
  apply_immediately      = true
  monitoring_interval    = 10

  skip_final_snapshot = true

  tags = local.common_tags
}

locals {
  environment = include.root.locals.account_vars.locals.aws_account
  region      = include.root.locals.region_vars.locals.aws_region

  common_tags = {
    Terraform   = "Managed"
    Environment = local.environment
  }
}