#
variable "name"                { type = string }
variable "kubernetes_version"  { default = "1.34" }
variable "vpc_id"              { type = string }
variable "subnet_ids"          { type = list(string) }
variable "node_instance_types" { default = ["t3.medium"] }
variable "node_min"            { default = 1 }
variable "node_max"            { default = 3 }
variable "node_desired"        { default = 2 }

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.31"

  cluster_name                             = var.name
  cluster_version                          = var.kubernetes_version
  cluster_endpoint_public_access           = true
  enable_cluster_creator_admin_permissions = true

  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  cluster_addons = {
    coredns    = {}
    kube-proxy = {}
    vpc-cni    = { before_compute = true }
  }

  # Lets the public NLB created by the k8s Service reach NodePorts
  node_security_group_additional_rules = {
    nodeports = {
      description = "NodePorts for NLB"
      protocol    = "tcp"
      from_port   = 30000
      to_port     = 32767
      type        = "ingress"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  eks_managed_node_groups = {
    default = {
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = var.node_instance_types
      min_size       = var.node_min
      max_size       = var.node_max
      desired_size   = var.node_desired
    }
  }
}

output "cluster_name"     { value = module.eks.cluster_name }
output "cluster_endpoint" { value = module.eks.cluster_endpoint }