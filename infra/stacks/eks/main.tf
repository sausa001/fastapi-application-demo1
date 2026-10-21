#
locals {
  name = "fastapi-aws-devops"
}

variable "create_vpc"          { default = false }
variable "existing_vpc_name"   { default = "" }
variable "vpc_cidr"            { default = "10.30.0.0/16" }
variable "kubernetes_version"  { default = "1.34" }
variable "node_instance_types" { default = ["t3.medium"] }
variable "node_min"            { default = 1 }
variable "node_max"            { default = 3 }
variable "node_desired"        { default = 2 }

module "network" {
  source            = "../../modules/network"
  create_vpc        = var.create_vpc
  name              = "${local.name}-eks"
  cidr              = var.vpc_cidr
  enable_nat        = true
  existing_vpc_name = var.existing_vpc_name
}

module "eks" {
  source              = "../../modules/eks"
  name                = "${local.name}-eks"
  kubernetes_version  = var.kubernetes_version
  vpc_id              = module.network.vpc_id
  subnet_ids          = module.network.private_subnet_ids
  node_instance_types = var.node_instance_types
  node_min            = var.node_min
  node_max            = var.node_max
  node_desired        = var.node_desired
}

output "cluster_name" { value = module.eks.cluster_name }
output "kubeconfig_cmd" {
  value = "aws eks update-kubeconfig --region ${var.region} --name ${module.eks.cluster_name}"
}