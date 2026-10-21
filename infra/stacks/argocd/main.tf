# has its own provider block, so we need to use the provider alias to avoid conflicts with the main provider block

terraform {
  required_version = ">= 1.10"
  required_providers {
    aws  = { source = "hashicorp/aws", version = "~> 5.0" }
    helm = { source = "hashicorp/helm", version = "~> 3.0" }
  }
  backend "s3" {}
}

variable "project"              { type = string }
variable "env"                  { type = string }
variable "region"               { type = string }
variable "stack"                { type = string }
variable "cluster_name"         { default = "" }          # default: <project>-<env>-eks
variable "argocd_chart_version" { default = "" }          # pin in prod, e.g. "7.x.y"
variable "server_service_type"  { default = "ClusterIP" } # or LoadBalancer

locals {
  cluster_name = var.cluster_name != "" ? var.cluster_name : "${var.project}-${var.env}-eks"
}

provider "aws" { region = var.region }

data "aws_eks_cluster" "this"      { name = local.cluster_name }
data "aws_eks_cluster_auth" "this" { name = local.cluster_name }

provider "helm" {
  kubernetes = {
    host                   = data.aws_eks_cluster.this.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  version          = var.argocd_chart_version != "" ? var.argocd_chart_version : null

  set = {
    name  = "server.service.type"
    value = var.server_service_type
  }
}

