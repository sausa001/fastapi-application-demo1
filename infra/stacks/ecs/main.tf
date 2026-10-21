#

variable "create_vpc"        { default = false }
variable "existing_vpc_name" { default = "" }
variable "vpc_cidr"          { default = "10.40.0.0/16" }
variable "container_image"   { type = string }

# locals {
#   name = "fastapi"
# }

module "network" {
  source            = "../../modules/network"
  create_vpc        = var.create_vpc
  name              = "${local.name}-ecs"
  cidr              = var.vpc_cidr
  enable_nat        = true
  existing_vpc_name = var.existing_vpc_name
}

module "ecs" {
  source             = "../../modules/ecs-service"
  name               = local.name
  vpc_id             = module.network.vpc_id
  public_subnet_ids  = module.network.public_subnet_ids
  private_subnet_ids = module.network.private_subnet_ids
  container_image    = var.container_image
}

output "alb_url" { value = module.ecs.alb_url }