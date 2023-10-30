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

// Note: Add the policy to the CloudFront origin after the policy has been
// added to the bucket. Best to add it to the bucket as soon as its made.
resource "aws_cloudfront_origin_access_control" "web" {
  name                              = "${var.domain_name}-oac"
  description                       = "Grant CloudFront origin access control permission to the S3 bucket ${var.domain_name}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_cache_policy" "web" {
  name        = "${var.domain_name}-cp"
  comment     = "${var.domain_name} cache policy"
  default_ttl = var.cf_cache_default_ttl
  max_ttl     = var.cf_cache_max_ttl
  min_ttl     = var.cf_cache_min_ttl
  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "none"
    }
    headers_config {
      header_behavior = "none"
    }
    query_strings_config {
      query_string_behavior = "none"
    }
  }
}

data "aws_cloudfront_origin_request_policy" "web" {
  // Do not use the policy AllViewerAndCloudFrontHeaders-2022-06 with S3, the signature gets messed up (tried on 10/28/2023)
  name = "Managed-AllViewerExceptHostHeader"
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
  http_version        = var.cf_http_version

  default_cache_behavior {
    allowed_methods          = var.cf_allowed_methods
    compress                 = var.cf_compress
    cached_methods           = var.cf_cached_methods
    target_origin_id         = var.domain_name
    viewer_protocol_policy   = var.viewer_protocol_policy
    cache_policy_id          = aws_cloudfront_cache_policy.web.id
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.web.id
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
