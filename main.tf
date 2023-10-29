moved {
  from = aws_route53_zone.app_domain
  to   = aws_route53_zone.web_hosted_zone
}

resource "aws_route53_zone" "web_hosted_zone" {
  count = var.hosted_zone_id == null ? 1 : 0
  name  = var.domain_name
}

moved {
  from = aws_route53_record.a_record
  to   = aws_route53_record.web_s3_alias
}

resource "aws_route53_record" "web_s3_alias" { # Map the domain to the S3 bucket
  depends_on = [
    aws_cloudfront_distribution.web
  ]

  allow_overwrite = true
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
