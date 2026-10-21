#DNS module for API Gateway custom domain name. Route 53, ACM, and the custom domain

variable "domain_name"        { type = string }      # example.com
variable "subdomain"          { default = "api" }
variable "create_hosted_zone" { default = false }    # true = new zone (then update NS at registrar)
variable "api_id"             { default = "" }       # empty = only zone + certificate

locals { fqdn = "${var.subdomain}.${var.domain_name}" }

resource "aws_route53_zone" "this" {
  count = var.create_hosted_zone ? 1 : 0
  name  = var.domain_name
}

data "aws_route53_zone" "this" {
  count        = var.create_hosted_zone ? 0 : 1
  name         = var.domain_name
  private_zone = false
}

locals {
  zone_id = one(concat(aws_route53_zone.this[*].zone_id, data.aws_route53_zone.this[*].zone_id))
}

resource "aws_acm_certificate" "api" {
  domain_name       = local.fqdn
  validation_method = "DNS"
  lifecycle { create_before_destroy = true }
}

resource "aws_route53_record" "validation" {
  for_each = {
    for dvo in aws_acm_certificate.api.domain_validation_options : dvo.domain_name => {
      name = dvo.resource_record_name, type = dvo.resource_record_type, value = dvo.resource_record_value
    }
  }
  zone_id         = local.zone_id
  name            = each.value.name
  type            = each.value.type
  records         = [each.value.value]
  ttl             = 60
  allow_overwrite = true
}

resource "aws_acm_certificate_validation" "api" {
  certificate_arn         = aws_acm_certificate.api.arn
  validation_record_fqdns = [for r in aws_route53_record.validation : r.fqdn]
}

resource "aws_apigatewayv2_domain_name" "api" {
  count       = var.api_id != "" ? 1 : 0
  domain_name = local.fqdn
  domain_name_configuration {
    certificate_arn = aws_acm_certificate_validation.api.certificate_arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}

resource "aws_apigatewayv2_api_mapping" "api" {
  count       = var.api_id != "" ? 1 : 0
  api_id      = var.api_id
  domain_name = aws_apigatewayv2_domain_name.api[0].id
  stage       = "$default"
}

resource "aws_route53_record" "api" {
  count   = var.api_id != "" ? 1 : 0
  zone_id = local.zone_id
  name    = local.fqdn
  type    = "A"
  alias {
    name                   = aws_apigatewayv2_domain_name.api[0].domain_name_configuration[0].target_domain_name
    zone_id                = aws_apigatewayv2_domain_name.api[0].domain_name_configuration[0].hosted_zone_id
    evaluate_target_health = false
  }
}

output "api_url"      { value = "https://${local.fqdn}" }
output "name_servers" { value = try(aws_route53_zone.this[0].name_servers, []) }