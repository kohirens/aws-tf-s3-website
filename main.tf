resource "aws_s3_bucket" "web" {
  bucket        = var.domain_name
  force_destroy = var.force_destroy

  tags = {
    module = "kohirens/aws-tf-s3-website"
  }
}

resource "aws_s3_bucket_acl" "web" {
  bucket = aws_s3_bucket.web.id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "web" {
  bucket                  = aws_s3_bucket.web.id
  block_public_acls       = true
  block_public_policy     = false
  ignore_public_acls      = true
  restrict_public_buckets = false
}

resource "aws_s3_bucket_versioning" "web" {
  bucket = aws_s3_bucket.web.id
  versioning_configuration {
    status = var.versioning ? "Enabled" : "Disabled"
  }
}

resource "aws_s3_bucket_website_configuration" "web" {
  bucket = aws_s3_bucket.web.id

  index_document {
    suffix = var.index_page
  }

  error_document {
    key = var.error_page
  }
}

resource "aws_route53_zone" "web_hosted_zone" {
  count = var.hosted_zone_id == null ? 1 : 0
  name  = var.domain_name
}

resource "aws_route53_record" "web_s3_alias" { # Map the domain to the S3 bucket
  allow_overwrite = false
  name            = var.domain_name
  type            = "A"
  zone_id         = var.hosted_zone_id == null ? aws_route53_zone.web_hosted_zone[0].zone_id : var.hosted_zone_id

  alias {
    # This is a list kept by AWS here: https://docs.aws.amazon.com/general/latest/gr/s3.html#s3_website_region_endpoints
    evaluate_target_health = var.evaluate_target_health
    name                   = aws_cloudfront_distribution.web.domain_name
    zone_id                = aws_cloudfront_distribution.web.hosted_zone_id
  }
}

provider "aws" {
  alias  = "us1"
  region = "us-east-1"
}

resource "aws_acm_certificate" "web" {
  provider          = aws.us1
  count             = var.cf_acm_certificate_arn == null ? 1 : 0 # Don't make a cert if one is passed in.
  domain_name       = var.domain_name
  validation_method = var.acm_validation_method
  key_algorithm     = var.cert_key_algorithm
  # skipping adding sans as other apps can start using your SSL cert
  # making unintended dependencies. Thus making it hard to tear down this
  # module.
  # subject_alternative_names = var.certificate_sans

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
  ttl             = 60
  type            = local.dvo_list[count.index].resource_record_type
  zone_id         = var.hosted_zone_id == null ? aws_route53_zone.web_hosted_zone[0].zone_id : var.hosted_zone_id
}

resource "aws_acm_certificate_validation" "web" {
  provider                = aws.us1
  count                   = length(aws_acm_certificate.web) > 0 ? 1 : 0 # Don't make a cert if one is passed in.
  certificate_arn         = aws_acm_certificate.web[0].arn
  validation_record_fqdns = [for record in aws_route53_record.acm_validations : record.fqdn]
}

resource "aws_cloudfront_origin_access_control" "web" {
  name                              = var.domain_name
  description                       = "${var.domain_name} Policy"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "web" {
  depends_on = [
    aws_s3_bucket.web,
    aws_acm_certificate.web,
    aws_acm_certificate_validation.web
  ]

  aliases             = [var.domain_name]
  enabled             = var.cf_enabled
  is_ipv6_enabled     = var.cf_is_ipv6_enabled
  retain_on_delete    = var.cf_retain_on_delete
  comment             = "${var.domain_name} website distribution"
  default_root_object = var.index_page
  price_class         = var.cf_price_class
  wait_for_deployment = var.cf_wait_for_deployment

  default_cache_behavior {
    allowed_methods        = var.cf_allowed_methods
    compress               = var.cf_compress
    cached_methods         = var.cf_cached_methods
    target_origin_id       = var.domain_name
    viewer_protocol_policy = var.viewer_protocol_policy
    min_ttl                = var.cf_cache_min_ttl
    default_ttl            = var.cf_cache_default_ttl
    max_ttl                = var.cf_cache_max_ttl

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  origin {
    domain_name              = aws_s3_bucket.web.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.web.id
    origin_id                = var.domain_name
  }

  restrictions {
    geo_restriction {
      locations        = var.cf_locations
      restriction_type = var.cf_restriction_type
    }
  }

  viewer_certificate {
    acm_certificate_arn            = var.cf_acm_certificate_arn != null ? var.cf_acm_certificate_arn : aws_acm_certificate.web[0].arn
    cloudfront_default_certificate = var.cloudfront_default_certificate
    minimum_protocol_version       = var.cf_minimum_protocol_version
    ssl_support_method             = var.cf_ssl_support_method
  }
}

resource "aws_s3_bucket_policy" "web" {
  depends_on = [
    aws_cloudfront_distribution.web
  ]

  bucket = aws_s3_bucket.web.id
  policy = templatefile(
    "${path.module}/bucket-policy.json",
    {
      account_no = var.aws_account
      bucket     = var.domain_name
      cfd_id     = aws_cloudfront_distribution.web.id
    }
  )
}