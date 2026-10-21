# The isolation switch. This module either creates its own VPC or looks up an existing one by its Name tag.
variable "create_vpc"        { type = bool }
variable "name"              { type = string }
variable "cidr"              { default = "10.99.0.0/16" }
variable "az_count"          { default = 2 }
variable "enable_nat"        { default = true }
variable "existing_vpc_name" { default = "" }   # used when create_vpc = false

module "vpc" {
  source     = "../vpc"
  count      = var.create_vpc ? 1 : 0
  name       = var.name
  cidr       = var.cidr
  az_count   = var.az_count
  enable_nat_gateway = var.enable_nat
}

data "aws_vpc" "existing" {
  count = var.create_vpc ? 0 : 1
  tags  = { Name = var.existing_vpc_name }
}

data "aws_subnets" "public" {
  count = var.create_vpc ? 0 : 1
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.existing[0].id]
  }
  tags = { Tier = "public" }
}

data "aws_subnets" "private" {
  count = var.create_vpc ? 0 : 1
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.existing[0].id]
  }
  tags = { Tier = "private" }
}

output "vpc_id" {
  value = one(concat(module.vpc[*].vpc_id, data.aws_vpc.existing[*].id))
}
output "public_subnet_ids" {
  value = concat(flatten(module.vpc[*].public_subnet_ids), flatten(data.aws_subnets.public[*].ids))
}
output "private_subnet_ids" {
  value = concat(flatten(module.vpc[*].private_subnet_ids), flatten(data.aws_subnets.private[*].ids))
}