#DNS module for API Gateway custom domain name. Route 53, ACM, and the custom domain
variable "domain_name"        { type = string }
variable "subdomain"          { default = "api" }
variable "create_hosted_zone" { default = false }
variable "api_id"             { default = "" }

module "dns" {
  source             = "../../modules/dns"
  domain_name        = var.domain_name
  subdomain          = var.subdomain
  create_hosted_zone = var.create_hosted_zone
  api_id             = var.api_id
}

output "api_url"      { value = module.dns.api_url }
output "name_servers" { value = module.dns.name_servers }

