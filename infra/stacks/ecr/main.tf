#
# locals {
#   name = "fastapi-aws-devops"
# }

module "ecr" {
  source = "../../modules/ecr"
  name   = local.name               # fastapi-demo-dev or fastapi-aws-devops
}

output "repository_url" { value = module.ecr.repository_url }