provider "aws" {
  alias  = "cloud_front"
  region = var.cf_region
}

resource "aws_acm_certificate" "web" {
  provider                  = aws.cloud_front
  count                     = var.cf_acm_certificate_arn == null ? 1 : 0 # Don't make a cert if one is passed in.
  domain_name               = var.domain_name
  validation_method         = var.acm_validation_method
  key_algorithm             = var.cert_key_algorithm
  subject_alternative_names = var.alt_domain_names

  lifecycle {
    create_before_destroy = true
  }
}

locals {
  # Could have just used tolist function, but this keeps our IDE from seeing red.
  dvo_list = [for dvo in aws_acm_certificate.web[0].domain_validation_options :
    {
      domain_name           = dvo.domain_name
      resource_record_name  = dvo.resource_record_name
      resource_record_value = dvo.resource_record_value
      resource_record_type  = dvo.resource_record_type
    }
    if length(aws_acm_certificate.web) > 0
  ]
}

resource "aws_route53_record" "acm_validations" {
  count = length(aws_acm_certificate.web) > 0 ? length(local.dvo_list) : 0

  allow_overwrite = true
  name            = local.dvo_list[count.index].resource_record_name
  records         = [local.dvo_list[count.index].resource_record_value]
  ttl             = 300
  type            = local.dvo_list[count.index].resource_record_type
  zone_id         = var.hosted_zone_id
}

resource "aws_acm_certificate_validation" "web" {
  count                   = length(aws_acm_certificate.web) > 0 ? 1 : 0 # Don't validate a cert if one is passed in.
  certificate_arn         = aws_acm_certificate.web[0].arn
  validation_record_fqdns = [for record in aws_route53_record.acm_validations : record.fqdn]
}
