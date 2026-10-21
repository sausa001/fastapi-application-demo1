# shared VPC for EKS and ECS

variable "vpc_cidr"   { default = "10.0.0.0/16" }
variable "az_count"   { default = 2 }
variable "enable_nat" { default = true }

module "vpc" {
  source     = "../../modules/vpc"
  name       = "${local.name}-vpc"   #Check if this is correct. It should be the same as the name of the VPC in the network module.
  cidr       = var.vpc_cidr
  az_count   = var.az_count
  enable_nat_gateway = var.enable_nat
}

output "vpc_id"             { value = module.vpc.vpc_id }
output "public_subnet_ids"  { value = module.vpc.public_subnet_ids }
output "private_subnet_ids" { value = module.vpc.private_subnet_ids }