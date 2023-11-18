locals {
  domains = concat([var.domain_name], var.alt_domain_names)

  authorization_header = var.authorization_code == null ? "" : "Basic ${var.authorization_code}"

  custom_headers = merge({ Authorization = local.authorization_header }, var.cf_custom_headers)

  lambda_func_url_domain = replace(
    replace(module.lambda_origin.function_url, "https://", "")
    , "/", ""
  )
}

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

# Route the domain to the CloudFront distribution.
resource "aws_route53_record" "web_s3_alias" {
  count = length(local.domains)
  depends_on = [
    aws_cloudfront_distribution.web
  ]

  allow_overwrite = true
  name            = local.domains[count.index]
  type            = "A"
  zone_id         = var.hosted_zone_id == null ? aws_route53_zone.web_hosted_zone[0].zone_id : var.hosted_zone_id

  alias {
    # This is a list kept by AWS here: https://docs.aws.amazon.com/general/latest/gr/s3.html#s3_website_region_endpoints
    evaluate_target_health = false # this is ignored when you use cloudfront as an Alias, but it is required.
    name                   = aws_cloudfront_distribution.web.domain_name
    zone_id                = aws_cloudfront_distribution.web.hosted_zone_id
  }
}

resource "aws_cloudfront_cache_policy" "web" {
  name        = "${replace(var.domain_name, ".", "-")}-cp"
  comment     = "cache policy for ${var.domain_name}"
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
  // Do not use the policy AllViewerAndCloudFrontHeaders-2022-06 with S3 and Lambda, the signature gets messed up (tried on 10/28/2023, 11/15/2023)
  name = "AllViewerAndCloudFrontHeaders-2022-06"
}

# Make an CloudFront function for the edge to copy the Host header in Client-Host.
# Copy the Host header into another header Hosts to preserve it as it goes
# through CloudFront.
# For details see: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_function
# TODO Add the CloudFront Function as an edge function to intercept the viewer's
# request before CloudFront forwards the request onto the origin and changes
# the Host to the origin's domain.
resource "aws_cloudfront_function" "web" {
  name    = "viewer-request-${replace(var.domain_name, ".", "-")}"
  runtime = "cloudfront-js-1.0"
  comment = "Pass the client requested domain to the origin by copying Host to another header Viewer-Host."
  publish = true
  code    = file("${path.module}/files/index.js")
}

resource "aws_cloudfront_distribution" "web" {
  depends_on = [
    aws_acm_certificate.web,
    aws_acm_certificate_validation.web
  ]

  aliases             = local.domains
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

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.web.arn
    }
  }

  origin {
    domain_name = local.lambda_func_url_domain
    origin_id   = "lambda-${replace(var.domain_name, ".", "-")}"

    dynamic "custom_header" {
      for_each = local.custom_headers
      content {
        name  = custom_header.key
        value = custom_header.value
      }
    }

    custom_origin_config {
      http_port              = "80"
      https_port             = "443"
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
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
