resource "aws_ec2_client_vpn_endpoint" "vpn" {
  description            = var.description
  vpc_id                 = var.vpc_id
  server_certificate_arn = var.server_certificate_arn
  client_cidr_block      = var.client_cidr_block
  self_service_portal    = "enabled"
  split_tunnel           = true
  security_group_ids     = var.security_group_ids
  # dns_servers            = var.dns_servers

  authentication_options {
    type                       = "certificate-authentication"
    root_certificate_chain_arn = var.server_certificate_arn
  }

  client_connect_options {
    enabled = false
  }

  client_login_banner_options {
    enabled = false
  }

  connection_log_options {
    enabled = false
  }

  tags = var.tags
}

resource "aws_ec2_client_vpn_network_association" "vpn-client" {
  count                  = length(var.vpn_subnets)
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vpn.id
  subnet_id              = var.vpn_subnets[count.index]
}

resource "aws_ec2_client_vpn_authorization_rule" "authorization_rule" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.vpn.id

  target_network_cidr  = var.vpc_cidr
  authorize_all_groups = true
}