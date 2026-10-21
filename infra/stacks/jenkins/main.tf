# fully standalone by default
# #
# locals {
#   name = "fastapi-application-demo1"
# }
# #
variable "create_vpc"        { default = true }   # own VPC -> zero dependencies
variable "existing_vpc_name" { default = "" }
variable "vpc_cidr"          { default = "10.10.0.0/16" }
variable "instance_type"     { default = "t3.medium" }
variable "key_name"          { default = "" }
variable "allowed_cidrs"     { type = list(string) }

module "network" {
  source            = "../../modules/network"
  create_vpc        = var.create_vpc
  name              = "${local.name}-jenkins"
  cidr              = var.vpc_cidr
  enable_nat        = false            # Jenkins sits in a public subnet; no NAT cost
  existing_vpc_name = var.existing_vpc_name
}

module "jenkins" {
  source        = "../../modules/jenkins-ec2"
  name          = "${local.name}-jenkins"
  vpc_id        = module.network.vpc_id
  subnet_id     = module.network.public_subnet_ids[0]
  instance_type = var.instance_type
  key_name      = var.key_name
  allowed_cidrs = var.allowed_cidrs
}

output "jenkins_url" { value = module.jenkins.jenkins_url }
output "instance_id" { value = module.jenkins.instance_id }
output "public_ip"   { value = module.jenkins.public_ip }

