variable "acm_validation_method" {
  default     = "DNS"
  description = "ACM validation method"
  type        = string
}

variable "all_http_methods" {
  default     = false
  description = "Allow all of the HTTP verbs default is (default is false which falls back to [\"GET\", \"HEAD\", \"OPTIONS\"]). This is done because of the weirdness where CloudFront only makes you choose a group for HTTP verbs."
  type        = bool
}

variable "alt_domain_names" {
  default     = []
  description = "A list of alternate domain names for the distribution and function."
  type        = list(string)
}

variable "aws_account" {
  description = "AWS account ID."
  type        = number
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "cert_key_algorithm" {
  default     = "EC_prime256v1"
  description = "Certificate key algorithm and level."
  type        = string
}

variable "cf_acm_certificate_arn" {
  default     = null
  description = "SSL certificate to use when viewing the site. Will avoid making a new ACM certificate when this is set."
  type        = string
}

variable "cf_additional_origins" {
  default     = {}
  description = "Additional origins to add to the distribution, please note that the keys of this map will be used for the origin_id."
  type = map(object({
    # origin_id = this objects' key
    connection_attempts = optional(number, 3)
    connection_timeout  = optional(number, 10)
    custom_origin_config = optional(list(object({
      http_port                = string
      https_port               = string
      origin_protocol_policy   = string
      origin_ssl_protocols     = list(string)
      origin_keepalive_timeout = optional(number)
      origin_read_timeout      = optional(number)
    })), [])
    domain_name              = string
    custom_headers           = optional(map(string))
    origin_access_control_id = optional(string)
    origin_path              = optional(string)
    origin_shield = optional(object({
      enabled              = bool
      origin_shield_region = optional(string)
    }))
    s3_origin_config = optional(object({
      origin_access_identity = string
    }))
    vpc_origin_config = optional(object({
      vpc_origin_id            = string
      origin_keepalive_timeout = optional(number)
      origin_read_timeout      = optional(number)
    }))
  }))
}

variable "cf_additional_ordered_cache_behaviors" {
  default     = []
  description = "Additional ordered cache behaviors to add to the distribution, please note that you can set target_origin_id to the generated origin id to reuse an new/existing origin."
  type = list(object({
    allowed_methods          = optional(list(string)) # fallback to local.cf_http_methods
    cache_policy_id          = optional(string)
    cached_methods           = optional(list(string)) # fallback to var.cf_cached_methods
    compress                 = optional(bool, false)
    default_ttl              = optional(number)
    max_ttl                  = optional(number)
    min_ttl                  = optional(number, 0)
    origin_request_policy_id = optional(string)
    path_pattern             = string
    smooth_streaming         = optional(bool, false)
    target_origin_id         = string
    viewer_protocol_policy   = optional(string) # fallback to var.viewer_protocol_policy
    grpc_config = optional(object({
      enabled = bool
    }))
  }))
}

variable "cf_cache_default_ttl" {
  default     = 3600
  description = "Default cache life in seconds."
  type        = number
}

variable "cf_cache_max_ttl" {
  default     = 86400
  description = "Max cache life in seconds."
  type        = number
}

variable "cf_cached_methods" {
  default     = ["GET", "HEAD"]
  description = "HTTP method verbs like GET and POST."
  type        = list(string)
}

variable "cf_cache_min_ttl" {
  default     = 0
  description = "Minimum cache life."
  type        = string
}

variable "cf_cache_cookie_behavior" {
  default     = "none"
  description = "Determines whether any cookies in viewer requests are included in the origin request key and automatically included in requests that CloudFront sends to the origin."
  type        = string
  validation {
    condition     = contains(["none", "whitelist", "all"], var.cf_cache_cookie_behavior)
    error_message = "value must be one of the following values: "
  }
}

variable "cf_cache_cookies" {
  default     = null
  description = "A list of HTTP cookie names to include in the CloudFront cache key."
  type        = list(string)
}

variable "cf_cache_header_behavior" {
  default     = "whitelist"
  description = "Determines whether any HTTP headers are included in the origin request key and automatically included in requests that CloudFront sends to the origin."
  type        = string
  validation {
    condition     = contains(["none", "whitelist", "allViewer", "allViewerAndWhitelistCloudFront"], var.cf_cache_header_behavior)
    error_message = "value must be one of the following values: "
  }
}

variable "cf_cache_headers" {
  default     = ["viewer-host"]
  description = "A list of HTTP headers names to include in the CloudFront cache key."
  type        = list(string)
}

variable "cf_cache_policy" {
  default     = null
  description = "Provide the name of an existing cache policy to use. Setting variables that build a cache policy are ignored."
  type        = string
}

variable "cf_cache_query_string_behavior" {
  default     = "none"
  description = "Whether URL query strings in viewer requests are included in the cache key and automatically included in requests."
  type        = string
  validation {
    condition     = contains(["none", "whitelist", "all"], var.cf_cache_query_string_behavior)
    error_message = "value must be one of the following values: "
  }
}

variable "cf_cache_query_strings" {
  default     = null
  description = "Configuration parameter that contains a list of query string parameter names. Just the name of the parameter is needed in this list."
  type        = list(string)
}

variable "cf_compress" {
  default     = true
  description = "HTTP method verbs like GET and POST."
  type        = bool
}

variable "cf_custom_headers" {
  default     = {}
  description = "Map of custom headers, where the key is the header name."
  type        = map(string)
}

variable "cf_enabled" {
  default     = true
  description = "Enable/Disable the distribution."
  type        = bool
}

variable "cf_http_version" {
  default     = "http2and3"
  description = "Maximum HTTP version to support on the distribution. Allowed values are http1.1, http2, http2and3 and http3. The default is http2."
  type        = string
}

variable "cf_is_ipv6_enabled" {
  default     = true
  description = "Enable IPv6."
  type        = bool
}

variable "cf_locations" {
  default     = ["US"]
  description = "Enable/Disable the distribution."
  type        = list(string)
}

variable "cf_minimum_protocol_version" {
  default     = "TLSv1.2_2021"
  description = "The minimum version of the SSL protocol that you want CloudFront to use for HTTPS connections.Can set to be one of [SSLv3 TLSv1 TLSv1_2016 TLSv1.1_2016 TLSv1.2_2018 TLSv1.2_2019 TLSv1.2_2021], see options here https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/secure-connections-supported-viewer-protocols-ciphers.html"
  type        = string
}

variable "cf_origin_path_lambda" {
  default     = ""
  description = "Causes CloudFront to request your content from a directory in your default Lambda origin."
  type        = string
}

variable "cf_origin_path_s3" {
  default     = ""
  description = "Causes CloudFront to request your content from a directory in your S3 origin."
  type        = string
}

variable "cf_origin_request_policy" {
  default     = "Managed-AllViewerExceptHostHeader"
  description = "Provide the name of an origin request policy to use."
  type        = string
}

variable "cf_path_pattern" {
  default     = "/assets/*"
  description = "Pattern (for example, images/*.jpg) that specifies which requests you want this cache behavior to apply to."
  type        = string
}

variable "cf_price_class" {
  default     = "PriceClass_100"
  description = "Options are [PriceClass_All, PriceClass_200, PriceClass_100], see https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/PriceClass.html."
  type        = string
}

variable "cf_region" {
  default     = "us-east-1"
  description = "The regions where CloudFront expects your ACM certificate."
  type        = string
}

variable "cf_restriction_type" {
  default     = "whitelist"
  description = "GEO location restrictions."
  type        = string
}

variable "cf_retain_on_delete" {
  default     = false
  description = "False to delete the distribution on destroy, and true to disable it."
  type        = bool
}

variable "cf_ssl_support_method" {
  default     = "sni-only"
  description = "Specifies how you want CloudFront to serve HTTPS requests. One of `vip` or `sni-only`. Required if you specify acm_certificate_arn or iam_certificate_id. NOTE: vip causes CloudFront to use a dedicated IP address and may incur extra charges."
  type        = string
}

variable "viewer_protocol_policy" {
  default     = "redirect-to-https"
  description = "to be one of [allow-all https-only redirect-to-https]."
  type        = string
}

variable "cf_wait_for_deployment" {
  default     = true
  description = "Wait for the CloudFront Distribution status to change from `Inprogress` to `Deployed`."
  type        = bool
}

variable "cloudfront_default_certificate" {
  default     = false
  description = "When you want viewers to use HTTPS to request your objects and you're using the CloudFront domain name for your distribution."
  type        = bool
}


variable "domain_name" {
  description = "The website domain name, for example: test.example.com."
  type        = string
}

variable "error_page" {
  default     = "400.html"
  description = "Error page for 4xx HTTP status errors."
  type        = string
}

variable "force_destroy" {
  description = "Setting this to true will allow the bucket and it content to be deleted on teardown or any action that causes a Terraform replace."
  type        = bool
  default     = true
}

variable "hosted_zone_id" {
  default     = null
  description = "Use an existing hosted zone to add an A record for the `domain_name`. When this is set, it will skip making a new hosted zone for the domain_name."
  type        = string
}

variable "iac_source" {
  description = "Version control repository for where the module was configured and deployed from."
  type        = string
}

variable "index_page" {
  default     = "index.html"
  description = "Set the home page."
  type        = string
}

variable "s3_enable_versioning" {
  default     = false
  description = "Enable S3 versioning by setting to true, or disable with false."
  type        = bool
}
