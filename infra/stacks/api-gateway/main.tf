#

locals {
  name = "fastapi-aws-devops"
}
variable "backend_url" { type = string }

module "api" {
  source      = "../../modules/api-gateway"
  name        = "${local.name}-api"
  backend_url = var.backend_url
}

output "api_id"       { value = module.api.api_id }
output "api_endpoint" { value = module.api.api_endpoint }