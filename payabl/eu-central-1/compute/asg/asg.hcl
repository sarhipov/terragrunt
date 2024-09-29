/// asg.hcl
terraform {
  source = "tfr:///terraform-aws-modules/autoscaling/aws//?version=8.0.0"
}

dependency "vpc" {
  config_path = "${get_terragrunt_dir()}/../../../network/vpc/main"
}

dependency "ssh-keys" {
  config_path = "${get_terragrunt_dir()}/../../ssh-keys/ec2-key"
}

dependency "security-group" {
  config_path = "${get_terragrunt_dir()}/../../../network/security-groups/${basename(get_terragrunt_dir())}-node"
}

locals {
  common_inputs = {
    # Autoscaling group
    name            = "${basename(get_terragrunt_dir())}-asg"
    use_name_prefix = false
    instance_name   = "${basename(get_terragrunt_dir())}-instance"

    min_size                  = 2
    max_size                  = 5
    desired_capacity          = 3
    wait_for_capacity_timeout = 0
    health_check_type         = "EC2" # ELB

    autoscaling_group_tags = {
      "Tier" = "${basename(get_terragrunt_dir())}"
    }

    # Launch template
    create_launch_template          = true
    launch_template_name            = "${basename(get_terragrunt_dir())}-asg"
    launch_template_use_name_prefix = false
    launch_template_description     = "Launch template for ${basename(get_terragrunt_dir())}-asg"
    update_default_version          = true

    create_iam_instance_profile = true
    iam_instance_profile_name   = "${basename(get_terragrunt_dir())}-role"
    iam_role_name               = "${basename(get_terragrunt_dir())}-role"
    iam_role_policies = {
      AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    }
    iam_role_use_name_prefix = false

    image_id      = "ami-0a0d2ca99b40eb592"
    instance_type = "t4g.medium"

    ebs_optimized = true

    block_device_mappings = [
      {
        # Root volume
        device_name = "/dev/xvda"
        no_device   = 0
        ebs = {
          delete_on_termination = true
          encrypted             = true
          volume_size           = 40
          volume_type           = "gp3"
        }
      },
    ]

    user_data = base64encode(file("${get_terragrunt_dir()}/files/user_data.sh"))
  }
}