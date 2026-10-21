# Common variables for all stacks

terraform {
  required_version = ">= 1.10"
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
  }
  backend "s3" {}
}

variable "project" { type = string }
variable "env"     { type = string }
variable "region"  { type = string }
variable "stack"   { type = string }

provider "aws" {
  region = var.region
  default_tags {
    tags = { Project = var.project, Environment = var.env, Stack = var.stack, ManagedBy = "terraform" }
  }
}

locals { name = "${var.project}-${var.env}" }

#for s in vpc jenkins ecr eks ecs api-gateway dns; do cp infra/stacks/_common/common.tf infra/stacks/$s/; done