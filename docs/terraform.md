<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.89.0 |
| <a name="provider_aws.cloud_front"></a> [aws.cloud\_front](#provider\_aws.cloud\_front) | 5.89.0 |
| <a name="provider_sh"></a> [sh](#provider\_sh) | 0.1.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_lambda_origin"></a> [lambda\_origin](#module\_lambda\_origin) | github.com/kohirens/aws-tf-lambda-function//. | 2.1.1 |

## Resources

| Name | Type |
|------|------|
| [aws_acm_certificate.web](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate) | resource |
| [aws_acm_certificate_validation.web](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate_validation) | resource |
| [aws_cloudfront_cache_policy.cf_s3_origin](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_cache_policy) | resource |
| [aws_cloudfront_distribution.web](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution) | resource |
| [aws_cloudfront_function.web](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_function) | resource |
| [aws_cloudfront_origin_access_control.lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_access_control) | resource |
| [aws_cloudfront_origin_access_control.web](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_access_control) | resource |
| [aws_iam_role_policy.lambda_s3_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_lambda_permission.allow_cloudfront](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_route53_record.acm_validations](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.web](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_s3_bucket.web](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_policy.web](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.web](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_versioning.web](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_cloudfront_cache_policy.disabled](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/cloudfront_cache_policy) | data source |
| [aws_cloudfront_cache_policy.s3_default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/cloudfront_cache_policy) | data source |
| [aws_cloudfront_cache_policy.s3_origin](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/cloudfront_cache_policy) | data source |
| [aws_cloudfront_origin_request_policy.all_but_host](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/cloudfront_origin_request_policy) | data source |
| [aws_cloudfront_origin_request_policy.web](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/cloudfront_origin_request_policy) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [sh_vars.lambda](https://registry.terraform.io/providers/kohirens/sh/latest/docs/data-sources/vars) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_acm_validation_method"></a> [acm\_validation\_method](#input\_acm\_validation\_method) | ACM validation method | `string` | `"DNS"` | no |
| <a name="input_all_http_methods"></a> [all\_http\_methods](#input\_all\_http\_methods) | Allow all of the HTTP verbs default is (default is false which falls back to ["GET", "HEAD", "OPTIONS"]). This is done because of the weirdness where CloudFront only makes you choose a group for HTTP verbs. | `bool` | `false` | no |
| <a name="input_alt_domain_names"></a> [alt\_domain\_names](#input\_alt\_domain\_names) | A list of alternate domain names for the distribution and function. | `list(string)` | `[]` | no |
| <a name="input_aws_account"></a> [aws\_account](#input\_aws\_account) | AWS account ID. | `number` | `0` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region | `string` | `""` | no |
| <a name="input_cert_key_algorithm"></a> [cert\_key\_algorithm](#input\_cert\_key\_algorithm) | Certificate key algorithm and level. | `string` | `"EC_prime256v1"` | no |
| <a name="input_cf_acm_certificate_arn"></a> [cf\_acm\_certificate\_arn](#input\_cf\_acm\_certificate\_arn) | SSL certificate to use when viewing the site. Will avoid making a new ACM certificate when this is set. | `string` | `null` | no |
| <a name="input_cf_additional_ordered_cache_behaviors"></a> [cf\_additional\_ordered\_cache\_behaviors](#input\_cf\_additional\_ordered\_cache\_behaviors) | Additional ordered cache behaviors to add to the distribution, please note that you can set target\_origin\_id to the generated origin id to reuse an new/existing origin. | <pre>list(object({<br/>    allowed_methods          = optional(list(string)) # fallback to local.cf_http_methods<br/>    cache_policy_id          = optional(string)<br/>    cached_methods           = optional(list(string)) # fallback to var.cf_cached_methods<br/>    compress                 = optional(bool, false)<br/>    default_ttl              = optional(number)<br/>    max_ttl                  = optional(number)<br/>    min_ttl                  = optional(number, 0)<br/>    origin_request_policy_id = optional(string)<br/>    path_pattern             = string<br/>    smooth_streaming         = optional(bool, false)<br/>    target_origin_id         = string<br/>    viewer_protocol_policy   = optional(string) # fallback to var.viewer_protocol_policy<br/>    grpc_config = optional(object({<br/>      enabled = bool<br/>    }))<br/>  }))</pre> | `[]` | no |
| <a name="input_cf_additional_origins"></a> [cf\_additional\_origins](#input\_cf\_additional\_origins) | Additional origins to add to the distribution, please note that the keys of this map will be used for the origin\_id. | <pre>map(object({<br/>    # origin_id = this objects' key<br/>    connection_attempts = optional(number, 3)<br/>    connection_timeout  = optional(number, 10)<br/>    custom_origin_config = optional(list(object({<br/>      http_port                = string<br/>      https_port               = string<br/>      origin_protocol_policy   = string<br/>      origin_ssl_protocols     = list(string)<br/>      origin_keepalive_timeout = optional(number)<br/>      origin_read_timeout      = optional(number)<br/>    })), [])<br/>    domain_name              = string<br/>    custom_headers           = optional(map(string))<br/>    origin_access_control_id = optional(string)<br/>    origin_path              = optional(string)<br/>    origin_shield = optional(object({<br/>      enabled              = bool<br/>      origin_shield_region = optional(string)<br/>    }))<br/>    s3_origin_config = optional(object({<br/>      origin_access_identity = string<br/>    }))<br/>    vpc_origin_config = optional(object({<br/>      vpc_origin_id            = string<br/>      origin_keepalive_timeout = optional(number)<br/>      origin_read_timeout      = optional(number)<br/>    }))<br/>  }))</pre> | `{}` | no |
| <a name="input_cf_cache_cookie_behavior"></a> [cf\_cache\_cookie\_behavior](#input\_cf\_cache\_cookie\_behavior) | Determines whether any cookies in viewer requests are included in the origin request key and automatically included in requests that CloudFront sends to the origin. | `string` | `"none"` | no |
| <a name="input_cf_cache_default_ttl"></a> [cf\_cache\_default\_ttl](#input\_cf\_cache\_default\_ttl) | Default cache life in seconds. | `number` | `3600` | no |
| <a name="input_cf_cache_header_behavior"></a> [cf\_cache\_header\_behavior](#input\_cf\_cache\_header\_behavior) | Determines whether any HTTP headers are included in the origin request key and automatically included in requests that CloudFront sends to the origin. | `string` | `"whitelist"` | no |
| <a name="input_cf_cache_max_ttl"></a> [cf\_cache\_max\_ttl](#input\_cf\_cache\_max\_ttl) | Max cache life in seconds. | `number` | `86400` | no |
| <a name="input_cf_cache_min_ttl"></a> [cf\_cache\_min\_ttl](#input\_cf\_cache\_min\_ttl) | Minimum cache life. | `string` | `0` | no |
| <a name="input_cf_cache_query_string_behavior"></a> [cf\_cache\_query\_string\_behavior](#input\_cf\_cache\_query\_string\_behavior) | Whether URL query strings in viewer requests are included in the cache key and automatically included in requests. | `string` | `"none"` | no |
| <a name="input_cf_cached_methods"></a> [cf\_cached\_methods](#input\_cf\_cached\_methods) | HTTP method verbs like GET and POST. | `list(string)` | <pre>[<br/>  "GET",<br/>  "HEAD"<br/>]</pre> | no |
| <a name="input_cf_compress"></a> [cf\_compress](#input\_cf\_compress) | HTTP method verbs like GET and POST. | `bool` | `true` | no |
| <a name="input_cf_custom_headers"></a> [cf\_custom\_headers](#input\_cf\_custom\_headers) | Map of custom headers, where the key is the header name. | `map(string)` | `{}` | no |
| <a name="input_cf_enabled"></a> [cf\_enabled](#input\_cf\_enabled) | Enable/Disable the distribution. | `bool` | `true` | no |
| <a name="input_cf_http_version"></a> [cf\_http\_version](#input\_cf\_http\_version) | Maximum HTTP version to support on the distribution. Allowed values are http1.1, http2, http2and3 and http3. The default is http2. | `string` | `"http2and3"` | no |
| <a name="input_cf_is_ipv6_enabled"></a> [cf\_is\_ipv6\_enabled](#input\_cf\_is\_ipv6\_enabled) | Enable IPv6. | `bool` | `true` | no |
| <a name="input_cf_locations"></a> [cf\_locations](#input\_cf\_locations) | Enable/Disable the distribution. | `list(string)` | <pre>[<br/>  "US"<br/>]</pre> | no |
| <a name="input_cf_minimum_protocol_version"></a> [cf\_minimum\_protocol\_version](#input\_cf\_minimum\_protocol\_version) | The minimum version of the SSL protocol that you want CloudFront to use for HTTPS connections.Can set to be one of [SSLv3 TLSv1 TLSv1\_2016 TLSv1.1\_2016 TLSv1.2\_2018 TLSv1.2\_2019 TLSv1.2\_2021], see options here https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/secure-connections-supported-viewer-protocols-ciphers.html | `string` | `"TLSv1.2_2021"` | no |
| <a name="input_cf_origin_path_lambda"></a> [cf\_origin\_path\_lambda](#input\_cf\_origin\_path\_lambda) | Causes CloudFront to request your content from a directory in your default Lambda origin. | `string` | `""` | no |
| <a name="input_cf_origin_path_s3"></a> [cf\_origin\_path\_s3](#input\_cf\_origin\_path\_s3) | Causes CloudFront to request your content from a directory in your S3 origin. | `string` | `""` | no |
| <a name="input_cf_origin_request_policy"></a> [cf\_origin\_request\_policy](#input\_cf\_origin\_request\_policy) | Provide the name of an origin request policy to use. | `string` | `"Managed-AllViewerExceptHostHeader"` | no |
| <a name="input_cf_path_pattern"></a> [cf\_path\_pattern](#input\_cf\_path\_pattern) | Pattern (for example, images/*.jpg) that specifies which requests you want this cache behavior to apply to. | `string` | `"/assets/*"` | no |
| <a name="input_cf_price_class"></a> [cf\_price\_class](#input\_cf\_price\_class) | Options are [PriceClass\_All, PriceClass\_200, PriceClass\_100], see https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/PriceClass.html. | `string` | `"PriceClass_100"` | no |
| <a name="input_cf_region"></a> [cf\_region](#input\_cf\_region) | The regions where CloudFront expects your ACM certificate. | `string` | `"us-east-1"` | no |
| <a name="input_cf_restriction_type"></a> [cf\_restriction\_type](#input\_cf\_restriction\_type) | GEO location restrictions. | `string` | `"whitelist"` | no |
| <a name="input_cf_retain_on_delete"></a> [cf\_retain\_on\_delete](#input\_cf\_retain\_on\_delete) | False to delete the distribution on destroy, and true to disable it. | `bool` | `false` | no |
| <a name="input_cf_s3_origin_cache_behavior_policy"></a> [cf\_s3\_origin\_cache\_behavior\_policy](#input\_cf\_s3\_origin\_cache\_behavior\_policy) | Provide the name of an existing cache policy to use. Setting variables that build a cache policy are ignored. | `string` | `""` | no |
| <a name="input_cf_s3_origin_cache_policy"></a> [cf\_s3\_origin\_cache\_policy](#input\_cf\_s3\_origin\_cache\_policy) | Provide the name of an existing cache policy to use. Setting variables that build a cache policy are ignored. | <pre>object({<br/>    default_ttl                   = number<br/>    max_ttl                       = number<br/>    min_ttl                       = optional(number, 0)<br/>    enable_accept_encoding_brotli = bool<br/>    enable_accept_encoding_gzip   = bool<br/>    cookie_behavior               = string<br/>    cookies                       = optional(list(string), [])<br/>    header_behavior               = string<br/>    query_string_behavior         = string<br/>    headers                       = optional(list(string), [])<br/>    query_strings                 = optional(list(string), [])<br/>  })</pre> | <pre>{<br/>  "cookie_behavior": "none",<br/>  "default_ttl": 3600,<br/>  "enable_accept_encoding_brotli": true,<br/>  "enable_accept_encoding_gzip": true,<br/>  "header_behavior": "none",<br/>  "max_ttl": 86400,<br/>  "min_ttl": 0,<br/>  "query_string_behavior": "none"<br/>}</pre> | no |
| <a name="input_cf_ssl_support_method"></a> [cf\_ssl\_support\_method](#input\_cf\_ssl\_support\_method) | Specifies how you want CloudFront to serve HTTPS requests. One of `vip` or `sni-only`. Required if you specify acm\_certificate\_arn or iam\_certificate\_id. NOTE: vip causes CloudFront to use a dedicated IP address and may incur extra charges. | `string` | `"sni-only"` | no |
| <a name="input_cf_wait_for_deployment"></a> [cf\_wait\_for\_deployment](#input\_cf\_wait\_for\_deployment) | Wait for the CloudFront Distribution status to change from `Inprogress` to `Deployed`. | `bool` | `true` | no |
| <a name="input_cloudfront_default_certificate"></a> [cloudfront\_default\_certificate](#input\_cloudfront\_default\_certificate) | When you want viewers to use HTTPS to request your objects and you're using the CloudFront domain name for your distribution. | `bool` | `false` | no |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | The website domain name, for example: test.example.com. | `string` | n/a | yes |
| <a name="input_error_page"></a> [error\_page](#input\_error\_page) | Error page for 4xx HTTP status errors. | `string` | `"400.html"` | no |
| <a name="input_force_destroy"></a> [force\_destroy](#input\_force\_destroy) | Setting this to true will allow the bucket and it content to be deleted on teardown or any action that causes a Terraform replace. | `bool` | `true` | no |
| <a name="input_hosted_zone_id"></a> [hosted\_zone\_id](#input\_hosted\_zone\_id) | Add A record for the `domain_name`. | `string` | n/a | yes |
| <a name="input_iac_source"></a> [iac\_source](#input\_iac\_source) | Version control repository for where the module was configured and deployed from. | `string` | n/a | yes |
| <a name="input_index_page"></a> [index\_page](#input\_index\_page) | Set the home page. | `string` | `"index.html"` | no |
| <a name="input_lf_architecture"></a> [lf\_architecture](#input\_lf\_architecture) | Instruction set architecture for your Lambda function. Valid values are x86\_64 or arm64. Mind the square brackets and quotes. | `string` | `"arm64"` | no |
| <a name="input_lf_description"></a> [lf\_description](#input\_lf\_description) | Provide a description | `string` | `null` | no |
| <a name="input_lf_environment_vars"></a> [lf\_environment\_vars](#input\_lf\_environment\_vars) | A map of environment variables. | `map(string)` | `null` | no |
| <a name="input_lf_external_env_vars"></a> [lf\_external\_env\_vars](#input\_lf\_external\_env\_vars) | Pull variables from the shell environment and pass them along to Lambda. | `list(string)` | `null` | no |
| <a name="input_lf_handler"></a> [lf\_handler](#input\_lf\_handler) | Function entrypoint in your code (name of the executable for binaries. | `string` | `"bootstrap"` | no |
| <a name="input_lf_invoke_mode"></a> [lf\_invoke\_mode](#input\_lf\_invoke\_mode) | Determines how the Lambda function responds to an invocation. Valid values are BUFFERED and RESPONSE\_STREAM. | `string` | `"BUFFERED"` | no |
| <a name="input_lf_log_retention_in_days"></a> [lf\_log\_retention\_in\_days](#input\_lf\_log\_retention\_in\_days) | Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653, and 0. If you select 0 they never expire. | `number` | `14` | no |
| <a name="input_lf_policy_path"></a> [lf\_policy\_path](#input\_lf\_policy\_path) | Path to a IAM policy for the Lambda function. | `string` | `null` | no |
| <a name="input_lf_reserved_concurrent_executions"></a> [lf\_reserved\_concurrent\_executions](#input\_lf\_reserved\_concurrent\_executions) | Amount of reserved concurrent executions for this lambda function. A value of 0 disables lambda from being triggered and -1 removes any concurrency limitations. Defaults to Unreserved Concurrency Limits. | `string` | `-1` | no |
| <a name="input_lf_role_arn"></a> [lf\_role\_arn](#input\_lf\_role\_arn) | ARN for the function to assume, this will be used instad of making a new role. | `string` | `null` | no |
| <a name="input_lf_runtime"></a> [lf\_runtime](#input\_lf\_runtime) | Identifier of the function's runtime. See https://docs.aws.amazon.com/lambda/latest/dg/API_CreateFunction.html#SSS-CreateFunction-request-Runtime | `string` | `"provided.al2"` | no |
| <a name="input_lf_source_file"></a> [lf\_source\_file](#input\_lf\_source\_file) | a file to zip up for your Lambda. Works well apps that build to a single binary. | `string` | `null` | no |
| <a name="input_lf_source_zip"></a> [lf\_source\_zip](#input\_lf\_source\_zip) | Supply your own zip for he Lambda. | `string` | `"bootstrap.zip"` | no |
| <a name="input_lf_url_alias"></a> [lf\_url\_alias](#input\_lf\_url\_alias) | n/a | `string` | `null` | no |
| <a name="input_lf_url_cors_allowed_headers"></a> [lf\_url\_cors\_allowed\_headers](#input\_lf\_url\_cors\_allowed\_headers) | HTTP headers allowed. | `list(string)` | <pre>[<br/>  "date",<br/>  "keep-alive"<br/>]</pre> | no |
| <a name="input_lf_url_cors_allowed_methods"></a> [lf\_url\_cors\_allowed\_methods](#input\_lf\_url\_cors\_allowed\_methods) | List of HTTP verbs allowed. | `list(string)` | <pre>[<br/>  "GET",<br/>  "POST"<br/>]</pre> | no |
| <a name="input_lf_url_cors_allowed_origins"></a> [lf\_url\_cors\_allowed\_origins](#input\_lf\_url\_cors\_allowed\_origins) | List of HTTP methods allowed. | `list(string)` | <pre>[<br/>  "*"<br/>]</pre> | no |
| <a name="input_lf_url_cors_headers_to_expose"></a> [lf\_url\_cors\_headers\_to\_expose](#input\_lf\_url\_cors\_headers\_to\_expose) | List of HTTP headers to expose in te response. | `list(string)` | <pre>[<br/>  "keep-alive",<br/>  "date"<br/>]</pre> | no |
| <a name="input_lf_url_cors_max_age"></a> [lf\_url\_cors\_max\_age](#input\_lf\_url\_cors\_max\_age) | The maximum amount of time, in seconds, that web browsers can cache results of a preflight request. The maximum value is 86400. | `number` | `0` | no |
| <a name="input_s3_enable_versioning"></a> [s3\_enable\_versioning](#input\_s3\_enable\_versioning) | Enable S3 versioning by setting to true, or disable with false. | `bool` | `false` | no |
| <a name="input_viewer_protocol_policy"></a> [viewer\_protocol\_policy](#input\_viewer\_protocol\_policy) | to be one of [allow-all, https-only, redirect-to-https]. | `string` | `"redirect-to-https"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket_arn"></a> [bucket\_arn](#output\_bucket\_arn) | The ARN of the bucket. |
| <a name="output_bucket_domain_name"></a> [bucket\_domain\_name](#output\_bucket\_domain\_name) | The bucket domain name. |
| <a name="output_bucket_hosted_zone_id"></a> [bucket\_hosted\_zone\_id](#output\_bucket\_hosted\_zone\_id) | The Route 53 Hosted Zone ID for this bucket's region. |
| <a name="output_bucket_regional_domain_name"></a> [bucket\_regional\_domain\_name](#output\_bucket\_regional\_domain\_name) | The bucket region-specific domain name. The bucket domain name including the region name, please refer here for format. Note: The AWS CloudFront allows specifying S3 region-specific endpoint when creating S3 origin, it will prevent redirect issues from CloudFront to S3 Origin URL. |
| <a name="output_certificate_arn"></a> [certificate\_arn](#output\_certificate\_arn) | ACM certificate ARN |
| <a name="output_distribution_domain_name"></a> [distribution\_domain\_name](#output\_distribution\_domain\_name) | CloudFront distribution domain name |
| <a name="output_distribution_hosted_zone_id"></a> [distribution\_hosted\_zone\_id](#output\_distribution\_hosted\_zone\_id) | Hosted zone ID of the CloudFront distribution |
| <a name="output_distribution_id"></a> [distribution\_id](#output\_distribution\_id) | ID of the CloudFront distribution |
| <a name="output_distribution_status"></a> [distribution\_status](#output\_distribution\_status) | Status of the CloudFront distribution |
| <a name="output_dvo_list"></a> [dvo\_list](#output\_dvo\_list) | Domain validation list |
| <a name="output_fqdn"></a> [fqdn](#output\_fqdn) | The FQDN pointing to the CloudFront distribution |
| <a name="output_function_arn"></a> [function\_arn](#output\_function\_arn) | Amazon Resource Name (ARN) identifying the Lambda function. |
| <a name="output_function_iam_policy_arn"></a> [function\_iam\_policy\_arn](#output\_function\_iam\_policy\_arn) | Amazon Resource Name (ARN) identifying the policy that is attached to the Lambda IAM role. |
| <a name="output_function_iam_role_arn"></a> [function\_iam\_role\_arn](#output\_function\_iam\_role\_arn) | Amazon Resource Name (ARN) identifying the IAM assigned to the Lambda function. |
| <a name="output_function_iam_role_name"></a> [function\_iam\_role\_name](#output\_function\_iam\_role\_name) | Name of the IAM role used when the lambda is executed. |
| <a name="output_function_log_group_arn"></a> [function\_log\_group\_arn](#output\_function\_log\_group\_arn) | CloudWatch Log group assigned to the lambda function for receiving logs. |
| <a name="output_function_memory_size"></a> [function\_memory\_size](#output\_function\_memory\_size) | Amount of memory in MB the Lambda function can use at runtime. |
| <a name="output_function_url"></a> [function\_url](#output\_function\_url) | URL assigned to the Lambda function. |
<!-- END_TF_DOCS -->