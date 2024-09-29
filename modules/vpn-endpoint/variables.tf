variable "description" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "client_cidr_block" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "security_group_ids" {
  type        = list(string)
}

variable "server_certificate_arn" {}

variable "tags" {
  type = map(any)
}

variable "vpn_subnets" {
  type = list(string)
}